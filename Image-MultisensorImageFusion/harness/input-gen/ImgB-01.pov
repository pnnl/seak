// PoVRay 3.7 Scene File " ImgA-01.pov"
// author:  Nitin A. Gawande
// date:    2016-03-07
// This file creates Image scene - 01 
//    with a different light settings and includes Targets
//--------------------------------------------------------------------------
#version 3.7;
global_settings{ assumed_gamma 1.0 }
#default{ finish{ ambient 0.1 diffuse 0.9 }} 
//--------------------------------------------------------------------------
#include "colors.inc"
#include "textures.inc"
#include "glass.inc"
#include "metals.inc"
#include "golds.inc"
#include "stones.inc"
#include "woods.inc"
#include "shapes.inc"
#include "shapes2.inc"
#include "functions.inc"
#include "math.inc"
#include "transforms.inc"
//--------------------------------------------------------------------------
// camera ------------------------------------------------------------------
#declare Camera_0 = camera {/*ultra_wide_angle*/ angle 75      // front view
                            location  <0.0 , 1.0 ,-3.0>
                            right     x*image_width/image_height
                            look_at   <0.0 , 1.0 , 0.0>}
#declare Camera_1 = camera {/*ultra_wide_angle*/ angle 90   // diagonal view
                            location  <2.0 , 2.5 ,-3.0>
                            right     x*image_width/image_height
                            look_at   <0.0 , 1.0 , 0.0>}
#declare Camera_2 = camera {/*ultra_wide_angle*/ angle 90 // right side view
                            location  <3.0 , 1.0 , 0.0>
                            right     x*image_width/image_height
                            look_at   <0.0 , 1.0 , 0.0>}
#declare Camera_3 = camera {/*ultra_wide_angle*/ angle 90        // top view
                            location  <0.0 , 3.0 ,-0.001>
                            right     x*image_width/image_height
                            look_at   <0.0 , 1.0 , 0.0>}
camera{Camera_0}   


// sun ---------------------------------------------------------------------
//light_source{<-1500,2500,-2500> color White}   
//light_source{<-1500,2500,-2500> color Orange}  
light_source{<-100,100,-2500> color Orange} 
    
//// set global atmospheric fog effect in the scene.
// at the fog distance, there will be 63% visibility
fog {
  fog_type 1               // 1=constant, 2=ground_fog
  distance 10
  color Gray               // can also have 'filter' and 'transmit'
  // (---turbulence---)
  //turbulence <0.5, 0.5, 1.0>
  //turb_depth 0.5
  //omega 0.5
  //lambda 2.0
  //octaves 6
  // (---ground fog---)
  //fog_offset 0.5         // height of constant fog
  //fog_alt 0.5            // at fog_offset+fog_alt: density=25%
}


// sky ---------------------------------------------------------------------
sky_sphere { pigment { gradient <0,1,0>
                       color_map { [0.00 rgb <1.0,1.0,1.0>]
                                   [0.30 rgb <0.0,0.1,1.0>]
                                   [0.70 rgb <0.0,0.1,1.0>]
                                   [1.00 rgb <1.0,1.0,1.0>] 
                                 } 
                       scale 2         
                     } // end of pigment
           } //end of skysphere

// fog ---------------------------------------------------------------------
fog{fog_type   2
    distance   50
    color      White
    fog_offset 0.1
    fog_alt    2.0
    turbulence 0.8}
// ground ------------------------------------------------------------------
plane{ <0,1,0>, 0 
       texture{ pigment{ color rgb <1.00,0.95,0.8>}
                normal { bumps 0.75 scale 0.025  }
                finish { phong 0.1 } 
              } // end of texture
     } // end of plane
//--------------------------------------------------------------------------
//---------------------------- objects in scene ----------------------------
//--------------------------------------------------------------------------





//n-com use of background above  and add mountain and grass




//---------------------------------------------------------------------
height_field{ png "Mount1.png" smooth double_illuminate
              // file types: 
              // gif | tga | pot | png | pgm | ppm | jpeg | tiff | sys
              // [water_level N] // truncate/clip below N (0.0 ... 1.0)
              translate<-0.5,-0.0,-0.5>
              scale<50,7,50>*1 
              texture{ pigment { color rgb <0.82,0.6,0.4>}
                       normal  { bumps 0.75 scale 0.025  }
                     } // end of texture
              rotate<0, 0,0>
              translate<2,0,30>
            } // end of height_field ----------------------------------
//---------------------------------------------------------------------



// -----------------------------------------------------------------------------------------------
// -----------------------------------------------------------------------------------------------
#declare Random_1 = seed (23484);
#declare Random_2 = seed (35271);
#declare Blade_Radius = 0.003;
#declare Blade_Height = 0.40;
//-------------------------------------------------------------
#declare objectPatch =
union{ //------------------------------------------------------
 #local Nr = 0;   // start
 #local End = 20; // end
 #while (Nr< End) 
     cone{ <0,0,0>,Blade_Radius,
           <0,Blade_Height*(1+0.15*rand(Random_1)),0>,0.001
           texture { pigment{ color rgb< 0.5, 1.0, 0.0>*0.5 }
                     normal { bumps 0.5 scale 0.05 }
                     finish { phong 1 reflection 0.00}
                   } // end of texture 
           translate<-0.15*rand(Random_2),0,0> 
           rotate<0,0,Nr*10/End> 
           rotate<0,Nr * 360/End+360*rand(Random_2),0>
         } //---------------------------
 #local Nr = Nr + 1;    // next Nr
 #end // ---------------  end of loop 
rotate<0,0,0>
translate<0,0,0>
} // end of union ---------------------------------------------
//-------------------------------------------------------------
//-------------------------------------------------------------
// -----------------------------------------------------------------------------------------------
#include "makegrass.inc"
// -----------------------------------------------------------------------------------------------
// Prairie parameters
#declare lPatch=0.5;               // size of patch
#declare nxPrairie=12;             // number of patches for the first line
#declare addPatches=1.5;            // number of patches to add at each line
#declare nzPrairie=35;             // number of lines of patches
#declare rd=seed(779);            // random seed
#declare stdscale=1.5;              // stddev of scale
#declare stdrotate=30;             // stddev of rotation
#declare doTest=0;//false;/true; or 0;/1; // replaces the patch with a sphere
// -----------------------------------------------------------------------------------------------
// -----------------------------------------------------------------------------------------------
// Create the prairie
object{MakePrairie(lPatch,nxPrairie,addPatches,nzPrairie,objectPatch,rd,stdscale,stdrotate,doTest)
// or optional: show Single Patch  
// object{  objectPatch
 scale 1 
 translate<0,0,-2>
}  
// -----------------------------------------------------------------------------------------------
// -----------------------------------------------------------------------------------------------



//------------------------------------------------------------- 
//------------------------------------------------------------- 
#declare Random_1 = seed (23484);
#declare Random_2 = seed (35271);
#declare Blade_Radius = 0.01;
#declare Blade_Height = 1.00; 

//-------------------------------------------------------------
union{ //------------------------------------------------------

 #local Nr = 0;   // start
 #local End = 70; // end
 #while (Nr< End) 
     cone{ <0,0,0>,Blade_Radius,
           <0,Blade_Height+0.050*rand(Random_1),0>,0.00
           texture { pigment{ color rgb< 0.5, 1.0, 0.0> } 
                     normal { bumps 0.5 scale 0.05 }
                     finish { phong 1 reflection 0.00}
                   } // end of texture 
           rotate<0,0,Nr*70/End> 
           translate<0,0,0> 
           rotate<0,Nr * 360/End+360*rand(Random_2),0>
         } //---------------------------

 #local Nr = Nr + 1;    // next Nr
 #end // ---------------  end of loop 

rotate<0,0,0>
translate<0,0,0>
} // end of union ---------------------------------------------
//------------------------------------------------------------- 
//------------------------------------------------------------- 



sphere{ <0,0,0> , 1.1
        texture{
          pigment{ crackle
                   scale 0.9 turbulence 0.35
                   color_map{
                     [0.01 color Black]
                     [0.02 color Black]
                     [0.32 color rgb<1,0.65,0>]
                     [1.00 color rgb<1,1.0,0.1>]
                     } // end of color_map
                    scale 0.1
                 } // end of pigment
          normal { bumps 0.75 scale 0.2}
          finish { diffuse 2.5 phong 1}
          rotate<0,-30,0>
          translate<0.01, 0.04, 0.00>
        } // end of texture -----------------------
   scale<0.1,0.1,0.1>  rotate<0,0,0>
   translate<0.40,1, 0.25>
 } // end of sphere -------------------------------
 
sphere{ <-10,0,0> , 1.3
        texture{
          pigment{ crackle
                   scale 0.9 turbulence 0.35
                   color_map{
                     /*[0.01 color Black]
                     [0.02 color Black]
                     [0.32 color rgb<1,0.65,0>]
                     [1.00 color rgb<1,1.0,0.1>]   */
                     [1.0  color Red]
                     [0.0  color Yellow]
                     [1.0  color Green]                     
                     } // end of color_map
                    scale 0.1
                 } // end of pigment
          normal { bumps 0.75 scale 0.2}
          finish { diffuse 10.5 phong 1}
          rotate<0,-30,0>
          translate<0.01, 0.04, 0.00>
        } // end of texture -----------------------
   scale<0.1,0.1,0.1>  rotate<0,0,0>
   translate<0.40,1, 0.25>
 } // end of sphere -------------------------------
 
sphere{ <14,-1,0> , 1.2
        texture{
          pigment{ crackle
                   scale 0.9 turbulence 0.35
                   color_map{
                     /*[0.01 color Black]
                     [0.02 color Black]
                     [0.32 color rgb<1,0.65,0>]
                     [1.00 color rgb<1,1.0,1.0>] */
                     [0.0  color Red]
                     [0.0  color Yellow]
                     [1.0  color Green]
                     } // end of color_map
                    scale 0.1
                 } // end of pigment
          normal { bumps 0.75 scale 0.2}
          finish { diffuse 10.5 phong 1}
          rotate<0,-30,0>
          translate<0.01, 0.04, 0.00>
        } // end of texture -----------------------
   scale<0.1,0.1,0.1>  rotate<0,0,0>
   translate<0.40,1, 0.25>
 } // end of sphere -------------------------------
 

 
    
   
