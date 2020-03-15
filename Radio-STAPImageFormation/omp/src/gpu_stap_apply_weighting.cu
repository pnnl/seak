/*
   This CUDA code is implementation of the kernel 
   space time adaptive processing - inner product
   as per C code in file stap_apply_weighting.c 
   provided with header as above

   The cuda implementation done by the team at PNNL
 */


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>

#include "stap_utils.h"

#define CUDA_SAFE(x) if ( cudaSuccess != (x) ) { printf("CUDA CALL FAILED AT %d\n", __LINE__ ); exit(1);}
#define CUDA_SAFE_MALLOC(DP, SIZE)  (cudaMalloc((void**)&DP, SIZE))

__constant__ complex steering_vectors[N_STEERING * (N_CHAN*TDOF)];

__global__ void gpu_compute_gamma_weights (complex *datacube, complex *adaptive_weights, complex *output)
{

		__shared__ complex shared_accum[N_CHAN*TDOF];
		__shared__ complex shared_accum_sv[N_STEERING];
		__shared__ float shared_gamma[N_STEERING];
		__shared__ complex shared_snapshot[N_CHAN*TDOF];

		//thread ID for given bock size and number of blocks
		int thread_number = (blockIdx.x + blockIdx.y*gridDim.x) * blockDim.x * blockDim.y
				+ (threadIdx.y * blockDim.x) + threadIdx.x;

		if(thread_number >= N_DOP * N_BLOCKS * N_CHAN * TDOF) return;

		int block = blockIdx.x;
		if(block >= N_BLOCKS) return;

		int dop_index = blockIdx.y;
		if(dop_index >= N_DOP) return;

		if(threadIdx.x >= N_CHAN * TDOF) return;

		int _i = threadIdx.x;

		int offset;

		shared_gamma[_i] = 0.0f;
		shared_accum_sv[_i].re = 0.0f;
		shared_accum_sv[_i].im = 0.0f;
		if((N_CHAN*TDOF) < N_STEERING)
		{
				if(threadIdx.x == 0) 
						for(int m = (N_CHAN*TDOF); m < N_STEERING; m++) 
						{
								shared_gamma[m] = 0.0f;
								shared_accum_sv[m].re = 0.0f;
								shared_accum_sv[m].im = 0.0f;
						}
		}
		__syncthreads();


		int sv;
		for (sv = 0; sv < N_STEERING; ++sv)
		{
				//accum.re = accum.im = 0.0f;
				shared_accum[_i].re = 0.0f;
				shared_accum[_i].im = 0.0f;

				//const complex prod = cmult(cconj(adaptive_weights[dop_index][range_block][sv][i]),steering_vectors[sv][i]);
				shared_accum[_i].re = adaptive_weights[dop_index*(N_BLOCKS*N_STEERING*N_CHAN*TDOF)+block*(N_STEERING*N_CHAN*TDOF)+sv*(N_CHAN*TDOF)+_i].re 
						* steering_vectors[sv*(N_CHAN*TDOF)+_i].re 
						+ adaptive_weights[dop_index*(N_BLOCKS*N_STEERING*N_CHAN*TDOF)+block*(N_STEERING*N_CHAN*TDOF)+sv*(N_CHAN*TDOF)+_i].im 
						* steering_vectors[sv*(N_CHAN*TDOF)+_i].im;

				shared_accum[_i].im = adaptive_weights[dop_index*(N_BLOCKS*N_STEERING*N_CHAN*TDOF)+block*(N_STEERING*N_CHAN*TDOF)+sv*(N_CHAN*TDOF)+_i].re 
						* steering_vectors[sv*(N_CHAN*TDOF)+_i].im 
						- adaptive_weights[dop_index*(N_BLOCKS*N_STEERING*N_CHAN*TDOF)+block*(N_STEERING*N_CHAN*TDOF)+sv*(N_CHAN*TDOF)+_i].im 
						* steering_vectors[sv*(N_CHAN*TDOF)+_i].re;

				__syncthreads();

				if(threadIdx.x == 0) 
				{
						for(int j = 0; j < N_CHAN*TDOF; j++)
						{
								shared_accum_sv[sv].re += shared_accum[j].re;
								shared_accum_sv[sv].im += shared_accum[j].im;
						}
				}
				__syncthreads();

		}

		offset = N_STEERING / 2;

		if(threadIdx.x < offset)
		{
				for (int j = 0; j < 2; j++)
				{
						shared_gamma[threadIdx.x+j*offset] = sqrt(shared_accum_sv[threadIdx.x+j*offset].re * shared_accum_sv[threadIdx.x+j*offset].re 
										+ shared_accum_sv[threadIdx.x+j*offset].im * shared_accum_sv[threadIdx.x+j*offset].im);

						if (shared_gamma[threadIdx.x+j*offset] > 0)
						{
								shared_gamma[threadIdx.x+j*offset] = 1.0f / shared_gamma[threadIdx.x+j*offset];
						}
						else
						{
								shared_gamma[threadIdx.x+j*offset] = 1.0f;
						}
				}
		}
		__syncthreads();

		int first_cell = block*TRAINING_BLOCK_SIZE;
		int last_cell = (block+1)*TRAINING_BLOCK_SIZE-1;

		for (int cell = first_cell; cell <= last_cell; ++cell)
		{
				int dof;
				int chan = threadIdx.x;

				if(chan < N_CHAN)
				{
						for (dof = 0; dof < TDOF; ++dof)
						{
								int dop = dop_index - (TDOF-1)/2 + dof;
								if (dop < 0) { dop += N_DOP; }
								if (dop >= N_DOP) { dop -= N_DOP; }

								//snapshot[chan*TDOF+dof] = datacube[chan][dop][range_cell];
								shared_snapshot[chan*TDOF+dof] = datacube[chan*(N_DOP*N_RANGE)+dop*N_RANGE+cell];
						}
				}

				__syncthreads();

				int sv;
				for(sv = 0; sv < N_STEERING; ++sv)
				{
						shared_accum[_i].re = 0.0f;
						shared_accum[_i].im = 0.0f;

						shared_accum[_i].re = adaptive_weights[dop_index*(N_BLOCKS*N_STEERING*N_CHAN*TDOF)+block*(N_STEERING*N_CHAN*TDOF)+sv*(N_CHAN*TDOF)+_i].re * shared_snapshot[_i].re 
								+ adaptive_weights[dop_index*(N_BLOCKS*N_STEERING*N_CHAN*TDOF)+block*(N_STEERING*N_CHAN*TDOF)+sv*(N_CHAN*TDOF)+_i].im * shared_snapshot[_i].im;

						shared_accum[_i].im = adaptive_weights[dop_index*(N_BLOCKS*N_STEERING*N_CHAN*TDOF)+block*(N_STEERING*N_CHAN*TDOF)+sv*(N_CHAN*TDOF)+_i].re * shared_snapshot[_i].im
								- adaptive_weights[dop_index*(N_BLOCKS*N_STEERING*N_CHAN*TDOF)+block*(N_STEERING*N_CHAN*TDOF)+sv*(N_CHAN*TDOF)+_i].im * shared_snapshot[_i].re;

						__syncthreads();

						if(threadIdx.x == 0) 
						{
								for(int j = 1; j < N_CHAN*TDOF; j++)
								{
										shared_accum[0].re += shared_accum[j].re;
										shared_accum[0].im += shared_accum[j].im;
								}
						}
						__syncthreads();

						if(threadIdx.x == 0) output[sv*(N_DOP*N_RANGE)+dop_index*N_RANGE+cell].re = shared_accum[0].re * shared_gamma[sv];
						if(threadIdx.x == 0) output[sv*(N_DOP*N_RANGE)+dop_index*N_RANGE+cell].im = shared_accum[0].im * shared_gamma[sv];
				}
		}

}


extern "C" int gpu_stap_apply_weighting( 
    complex output[N_STEERING][N_DOP][N_RANGE],
    complex (* const datacube)[N_DOP][N_RANGE],
    complex (* const adaptive_weights)[N_BLOCKS][N_STEERING][N_CHAN*TDOF],
    complex (* const _steering_vectors)[N_CHAN*TDOF])
{
		complex *dev_datacube;
		complex *dev_adaptive_weights;
		complex *dev_output;

		const int num_datacube = N_CHAN * N_DOP * N_RANGE;
		const int num_adaptive_weight_elements = N_DOP * N_BLOCKS * N_STEERING * (N_CHAN*TDOF);
		const int num_steering_vector_elements = N_STEERING * (N_CHAN*TDOF);
		const int num_output_elements = N_STEERING * N_DOP * N_RANGE;


		CUDA_SAFE(cudaMalloc((void **)&dev_datacube, num_datacube * sizeof(complex)));
		CUDA_SAFE(cudaMalloc((void **)&dev_adaptive_weights, num_adaptive_weight_elements * sizeof(complex)));
		CUDA_SAFE(cudaMalloc((void **)&dev_output, num_output_elements * sizeof(complex)));

		//copy data from host to device or initialize device variables
		CUDA_SAFE(cudaMemcpy(dev_datacube, datacube, num_datacube * sizeof(complex), cudaMemcpyHostToDevice));
		CUDA_SAFE(cudaMemcpy(dev_adaptive_weights, adaptive_weights, num_adaptive_weight_elements * sizeof(complex), cudaMemcpyHostToDevice));
		CUDA_SAFE(cudaMemcpyToSymbol(steering_vectors, _steering_vectors, num_steering_vector_elements * sizeof(complex), 0, cudaMemcpyHostToDevice));
		CUDA_SAFE(cudaMemset(dev_output, 0, num_output_elements * sizeof(complex)));

		//compute number of blocks for kernel launch
		dim3 grid_dim_01(N_BLOCKS,N_DOP,1);
		dim3 block_dim_01(N_CHAN * TDOF);

		gpu_compute_gamma_weights<<<grid_dim_01,block_dim_01>>>(dev_datacube, dev_adaptive_weights, dev_output);

		CUDA_SAFE(cudaDeviceSynchronize());

		//copy variable out back from Device to Host
		CUDA_SAFE(cudaMemcpy(output, dev_output, (num_output_elements * sizeof(complex)), cudaMemcpyDeviceToHost));

		//free device variables
		CUDA_SAFE(cudaFree(dev_datacube));
		CUDA_SAFE(cudaFree(dev_adaptive_weights));
		CUDA_SAFE(cudaFree(dev_output));

		return 0;
}
