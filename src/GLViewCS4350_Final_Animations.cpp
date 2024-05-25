#include "GLViewCS4350_Final_Animations.h"

#include "WorldList.h" //This is where we place all of our WOs
#include "ManagerOpenGLState.h" //We can change OpenGL State attributes with this
#include "Axes.h" //We can set Axes to on/off with this
#include "PhysicsEngineODE.h"

//Different WO used by this module
#include "WO.h"
#include "WOStatic.h"
#include "WOStaticPlane.h"
#include "WOStaticTrimesh.h"
#include "WOTrimesh.h"
#include "WOHumanCyborg.h"
#include "WOHumanCal3DPaladin.h"
#include "WOWayPointSpherical.h"
#include "WOLight.h"
#include "WOSkyBox.h"
#include "WOCar1970sBeater.h"
#include "Camera.h"
#include "CameraStandard.h"
#include "CameraChaseActorSmooth.h"
#include "CameraChaseActorAbsNormal.h"
#include "CameraChaseActorRelNormal.h"
#include "Model.h"
#include "ModelDataShared.h"
#include "ModelMesh.h"
#include "ModelMeshDataShared.h"
#include "ModelMeshSkin.h"
#include "WONVStaticPlane.h"
#include "WONVPhysX.h"
#include "WONVDynSphere.h"
#include "WOImGui.h" //GUI Demos also need to #include "AftrImGuiIncludes.h"
#include "AftrImGuiIncludes.h"
#include "AftrGLRendererBase.h"

using namespace Aftr;
using namespace std;



GLViewCS4350_Final_Animations* GLViewCS4350_Final_Animations::New( const std::vector< std::string >& args )
{
   GLViewCS4350_Final_Animations* glv = new GLViewCS4350_Final_Animations( args );
   glv->init( Aftr::GRAVITY, Vector( 0, 0, -1.0f ), "aftr.conf", PHYSICS_ENGINE_TYPE::petODE );
   glv->onCreate();
   return glv;
}


GLViewCS4350_Final_Animations::GLViewCS4350_Final_Animations( const std::vector< std::string >& args ) : GLView( args )
{
   //Initialize any member variables that need to be used inside of LoadMap() here.
   //Note: At this point, the Managers are not yet initialized. The Engine initialization
   //occurs immediately after this method returns (see GLViewCS4350_Final_Animations::New() for
   //reference). Then the engine invoke's GLView::loadMap() for this module.
   //After loadMap() returns, GLView::onCreate is finally invoked.

   //The order of execution of a module startup:
   //GLView::New() is invoked:
   //    calls GLView::init()
   //       calls GLView::loadMap() (as well as initializing the engine's Managers)
   //    calls GLView::onCreate()

   //GLViewCS4350_Final_Animations::onCreate() is invoked after this module's LoadMap() is completed.
}


void GLViewCS4350_Final_Animations::onCreate()
{
   //GLViewCS4350_Final_Animations::onCreate() is invoked after this module's LoadMap() is completed.
   //At this point, all the managers are initialized. That is, the engine is fully initialized.

   if( this->pe != NULL )
   {
      //optionally, change gravity direction and magnitude here
      //The user could load these values from the module's aftr.conf
      this->pe->setGravityNormalizedVector( Vector( 0,0,-1.0f ) );
      this->pe->setGravityScalar( Aftr::GRAVITY );
   }
   this->setActorChaseType( STANDARDEZNAV ); //Default is STANDARDEZNAV mode
   //this->setNumPhysicsStepsPerRender( 0 ); //pause physics engine on start up; will remain paused till set to 1
}


GLViewCS4350_Final_Animations::~GLViewCS4350_Final_Animations()
{
   //Implicitly calls GLView::~GLView()
}


void GLViewCS4350_Final_Animations::updateWorld()
{
   GLView::updateWorld(); //Just call the parent's update world first.
                          //If you want to add additional functionality, do it after
                          //this call.
}


void GLViewCS4350_Final_Animations::onResizeWindow( GLsizei width, GLsizei height )
{
   GLView::onResizeWindow( width, height ); //call parent's resize method.
}


void GLViewCS4350_Final_Animations::onMouseDown( const SDL_MouseButtonEvent& e )
{
   GLView::onMouseDown( e );
}


void GLViewCS4350_Final_Animations::onMouseUp( const SDL_MouseButtonEvent& e )
{
   GLView::onMouseUp( e );
}


void GLViewCS4350_Final_Animations::onMouseMove( const SDL_MouseMotionEvent& e )
{
   GLView::onMouseMove( e );
}


void GLViewCS4350_Final_Animations::onKeyDown( const SDL_KeyboardEvent& key )
{
   GLView::onKeyDown( key );
   if( key.keysym.sym == SDLK_0 )
      this->setNumPhysicsStepsPerRender( 1 );

   if( key.keysym.sym == SDLK_1 )
   {

   }
}


void GLViewCS4350_Final_Animations::onKeyUp( const SDL_KeyboardEvent& key )
{
   GLView::onKeyUp( key );
}


void Aftr::GLViewCS4350_Final_Animations::loadMap()
{
   this->worldLst = new WorldList(); //WorldList is a 'smart' vector that is used to store WO*'s
   this->actorLst = new WorldList();
   this->netLst = new WorldList();

   ManagerOpenGLState::GL_CLIPPING_PLANE = 1000.0;
   ManagerOpenGLState::GL_NEAR_PLANE = 0.1f;
   ManagerOpenGLState::enableFrustumCulling = false;
   Axes::isVisible = true;
   this->glRenderer->isUsingShadowMapping( false ); //set to TRUE to enable shadow mapping, must be using GL 3.2+

   this->cam->setPosition( 15,15,10 );

   std::string shinyRedPlasticCube( ManagerEnvironmentConfiguration::getSMM() + "/models/cube4x4x4redShinyPlastic_pp.wrl" );
   std::string wheeledCar( ManagerEnvironmentConfiguration::getSMM() + "/models/rcx_treads.wrl" );
   std::string grass( ManagerEnvironmentConfiguration::getSMM() + "/models/grassFloor400x400_pp.wrl" );
   std::string human( ManagerEnvironmentConfiguration::getSMM() + "/models/human_chest.wrl" );
   

   std::string bob(ManagerEnvironmentConfiguration::getLMM() + "/Content/boblampclean.md5mesh");
   std::string bobAnim(ManagerEnvironmentConfiguration::getLMM() + "/Content/boblampclean.md5anim");

   //SkyBox Textures readily available
   std::vector< std::string > skyBoxImageNames; //vector to store texture paths
   //skyBoxImageNames.push_back( ManagerEnvironmentConfiguration::getSMM() + "/images/skyboxes/sky_water+6.jpg" );
   //skyBoxImageNames.push_back( ManagerEnvironmentConfiguration::getSMM() + "/images/skyboxes/sky_dust+6.jpg" );
   skyBoxImageNames.push_back( ManagerEnvironmentConfiguration::getSMM() + "/images/skyboxes/sky_mountains+6.jpg" );
   //skyBoxImageNames.push_back( ManagerEnvironmentConfiguration::getSMM() + "/images/skyboxes/sky_winter+6.jpg" );
   //skyBoxImageNames.push_back( ManagerEnvironmentConfiguration::getSMM() + "/images/skyboxes/early_morning+6.jpg" );
   //skyBoxImageNames.push_back( ManagerEnvironmentConfiguration::getSMM() + "/images/skyboxes/sky_afternoon+6.jpg" );
   //skyBoxImageNames.push_back( ManagerEnvironmentConfiguration::getSMM() + "/images/skyboxes/sky_cloudy+6.jpg" );
   //skyBoxImageNames.push_back( ManagerEnvironmentConfiguration::getSMM() + "/images/skyboxes/sky_cloudy3+6.jpg" );
   //skyBoxImageNames.push_back( ManagerEnvironmentConfiguration::getSMM() + "/images/skyboxes/sky_day+6.jpg" );
   //skyBoxImageNames.push_back( ManagerEnvironmentConfiguration::getSMM() + "/images/skyboxes/sky_day2+6.jpg" );
   //skyBoxImageNames.push_back( ManagerEnvironmentConfiguration::getSMM() + "/images/skyboxes/sky_deepsun+6.jpg" );
   //skyBoxImageNames.push_back( ManagerEnvironmentConfiguration::getSMM() + "/images/skyboxes/sky_evening+6.jpg" );
   //skyBoxImageNames.push_back( ManagerEnvironmentConfiguration::getSMM() + "/images/skyboxes/sky_morning+6.jpg" );
   //skyBoxImageNames.push_back( ManagerEnvironmentConfiguration::getSMM() + "/images/skyboxes/sky_morning2+6.jpg" );
   //skyBoxImageNames.push_back( ManagerEnvironmentConfiguration::getSMM() + "/images/skyboxes/sky_noon+6.jpg" );
   //skyBoxImageNames.push_back( ManagerEnvironmentConfiguration::getSMM() + "/images/skyboxes/sky_warp+6.jpg" );
   //skyBoxImageNames.push_back( ManagerEnvironmentConfiguration::getSMM() + "/images/skyboxes/space_Hubble_Nebula+6.jpg" );
   //skyBoxImageNames.push_back( ManagerEnvironmentConfiguration::getSMM() + "/images/skyboxes/space_gray_matter+6.jpg" );
   //skyBoxImageNames.push_back( ManagerEnvironmentConfiguration::getSMM() + "/images/skyboxes/space_easter+6.jpg" );
   //skyBoxImageNames.push_back( ManagerEnvironmentConfiguration::getSMM() + "/images/skyboxes/space_hot_nebula+6.jpg" );
   //skyBoxImageNames.push_back( ManagerEnvironmentConfiguration::getSMM() + "/images/skyboxes/space_ice_field+6.jpg" );
   //skyBoxImageNames.push_back( ManagerEnvironmentConfiguration::getSMM() + "/images/skyboxes/space_lemon_lime+6.jpg" );
   //skyBoxImageNames.push_back( ManagerEnvironmentConfiguration::getSMM() + "/images/skyboxes/space_milk_chocolate+6.jpg" );
   //skyBoxImageNames.push_back( ManagerEnvironmentConfiguration::getSMM() + "/images/skyboxes/space_solar_bloom+6.jpg" );
   //skyBoxImageNames.push_back( ManagerEnvironmentConfiguration::getSMM() + "/images/skyboxes/space_thick_rb+6.jpg" );

   {
      //Create a light
      float ga = 0.1f; //Global Ambient Light level for this module
      ManagerLight::setGlobalAmbientLight( aftrColor4f( ga, ga, ga, 1.0f ) );
      WOLight* light = WOLight::New();
      light->isDirectionalLight( true );
      light->setPosition( Vector( 0, 0, 100 ) );
      //Set the light's display matrix such that it casts light in a direction parallel to the -z axis (ie, downwards as though it was "high noon")
      //for shadow mapping to work, this->glRenderer->isUsingShadowMapping( true ), must be invoked.
      light->getModel()->setDisplayMatrix( Mat4::rotateIdentityMat( { 0, 1, 0 }, 90.0f * Aftr::DEGtoRAD ) );
      light->setLabel( "Light" );
      worldLst->push_back( light );
   }

   {
      //Create the SkyBox
      WO* wo = WOSkyBox::New( skyBoxImageNames.at( 0 ), this->getCameraPtrPtr() );
      wo->setPosition( Vector( 0, 0, 0 ) );
      wo->setLabel( "Sky Box" );
      wo->renderOrderType = RENDER_ORDER_TYPE::roOPAQUE;
      worldLst->push_back( wo );
   }

   { 
      ////Create the infinite grass plane (the floor)
      WO* wo = WO::New( grass, Vector( 1, 1, 1 ), MESH_SHADING_TYPE::mstFLAT );
      wo->setPosition( Vector( 0, 0, 0 ) );
      wo->renderOrderType = RENDER_ORDER_TYPE::roOPAQUE;
      wo->upon_async_model_loaded( [wo]()
         {
            ModelMeshSkin& grassSkin = wo->getModel()->getModelDataShared()->getModelMeshes().at( 0 )->getSkins().at( 0 );
            grassSkin.getMultiTextureSet().at( 0 ).setTexRepeats( 5.0f );
            grassSkin.setAmbient( aftrColor4f( 0.4f, 0.4f, 0.4f, 1.0f ) ); //Color of object when it is not in any light
            grassSkin.setDiffuse( aftrColor4f( 1.0f, 1.0f, 1.0f, 1.0f ) ); //Diffuse color components (ie, matte shading color of this object)
            grassSkin.setSpecular( aftrColor4f( 0.4f, 0.4f, 0.4f, 1.0f ) ); //Specular color component (ie, how "shiney" it is)
            grassSkin.setSpecularCoefficient( 10 ); // How "sharp" are the specular highlights (bigger is sharper, 1000 is very sharp, 10 is very dull)
         } );
      wo->setLabel( "Grass" );
      worldLst->push_back( wo );
   }

   {
      
      WOAnim* wo = WOAnim::New( bob, Vector( 0.5, 0.5, 0.5 ), MESH_SHADING_TYPE::mstAUTO, woList,importer);
      wo->setPosition( Vector( 0, 0, 30 ) );
      wo->renderOrderType = RENDER_ORDER_TYPE::roOPAQUE;
       wo->upon_async_model_loaded( [wo]()
         {
            ModelMeshSkin& woSkin = wo->getModel()->getModelDataShared()->getModelMeshes().at( 0 )->getSkins().at( 0 );
            // grassSkin.getMultiTextureSet().at( 0 ).setTexRepeats( 5.0f );
            // woSkin.setAmbient( aftrColor4f( 0.4f, 0.4f, 0.4f, 1.0f ) ); //Color of object when it is not in any light
            woSkin.setDiffuse( aftrColor4f( 1.0f, 1.0f, 1.0f, 1.0f ) ); //Diffuse color components (ie, matte shading color of this object)
            woSkin.setSpecular( aftrColor4f( 0.4f, 0.4f, 0.4f, 1.0f ) ); //Specular color component (ie, how "shiney" it is)
            woSkin.setSpecularCoefficient( 10 ); // How "sharp" are the specular highlights (bigger is sharper, 1000 is very sharp, 10 is very dull)
         } );
      wo->setLabel( "bob" );
      worldLst->push_back( wo );

   }
   //{
   //   //Create the infinite grass plane that uses the Open Dynamics Engine (ODE)
   //   WO* wo = WOStatic::New( grass, Vector(1,1,1), MESH_SHADING_TYPE::mstFLAT );
   //   ((WOStatic*)wo)->setODEPrimType( ODE_PRIM_TYPE::PLANE );
   //   wo->setPosition( Vector(0,0,0) );
   //   wo->renderOrderType = RENDER_ORDER_TYPE::roOPAQUE;
   //   wo->getModel()->getModelDataShared()->getModelMeshes().at(0)->getSkins().at(0).getMultiTextureSet().at(0)->setTextureRepeats( 5.0f );
   //   wo->setLabel( "Grass" );
   //   worldLst->push_back( wo );
   //}

   //{
   //   //Create the infinite grass plane that uses NVIDIAPhysX(the floor)
   //   WO* wo = WONVStaticPlane::New( grass, Vector( 1, 1, 1 ), MESH_SHADING_TYPE::mstFLAT );
   //   wo->setPosition( Vector( 0, 0, 0 ) );
   //   wo->renderOrderType = RENDER_ORDER_TYPE::roOPAQUE;
   //   wo->getModel()->getModelDataShared()->getModelMeshes().at( 0 )->getSkins().at( 0 ).getMultiTextureSet().at( 0 )->setTextureRepeats( 5.0f );
   //   wo->setLabel( "Grass" );
   //   worldLst->push_back( wo );
   //}

   //{
   //   //Create the infinite grass plane (the floor)
   //   WO* wo = WONVPhysX::New( shinyRedPlasticCube, Vector( 1, 1, 1 ), MESH_SHADING_TYPE::mstFLAT );
   //   wo->setPosition( Vector( 0, 0, 50.0f ) );
   //   wo->renderOrderType = RENDER_ORDER_TYPE::roOPAQUE;
   //   wo->setLabel( "Grass" );
   //   worldLst->push_back( wo );
   //}

   //{
   //   WO* wo = WONVPhysX::New( shinyRedPlasticCube, Vector( 1, 1, 1 ), MESH_SHADING_TYPE::mstFLAT );
   //   wo->setPosition( Vector( 0, 0.5f, 75.0f ) );
   //   wo->renderOrderType = RENDER_ORDER_TYPE::roOPAQUE;
   //   wo->setLabel( "Grass" );
   //   worldLst->push_back( wo );
   //}

   //{
   //   WO* wo = WONVDynSphere::New( ManagerEnvironmentConfiguration::getVariableValue( "sharedmultimediapath" ) + "/models/sphereRp5.wrl", Vector( 1.0f, 1.0f, 1.0f ), mstSMOOTH );
   //   wo->setPosition( 0, 0, 100.0f );
   //   wo->setLabel( "Sphere" );
   //   this->worldLst->push_back( wo );
   //}

   //{
   //   WO* wo = WOHumanCal3DPaladin::New( Vector( .5, 1, 1 ), 100 );
   //   ((WOHumanCal3DPaladin*)wo)->rayIsDrawn = false; //hide the "leg ray"
   //   ((WOHumanCal3DPaladin*)wo)->isVisible = false; //hide the Bounding Shell
   //   wo->setPosition( Vector( 20, 20, 20 ) );
   //   wo->setLabel( "Paladin" );
   //   worldLst->push_back( wo );
   //   actorLst->push_back( wo );
   //   netLst->push_back( wo );
   //   this->setActor( wo );
   //}
   //
   //{
   //   WO* wo = WOHumanCyborg::New( Vector( .5, 1.25, 1 ), 100 );
   //   wo->setPosition( Vector( 20, 10, 20 ) );
   //   wo->isVisible = false; //hide the WOHuman's bounding box
   //   ((WOHuman*)wo)->rayIsDrawn = false; //show the 'leg' ray
   //   wo->setLabel( "Human Cyborg" );
   //   worldLst->push_back( wo );
   //   actorLst->push_back( wo ); //Push the WOHuman as an actor
   //   netLst->push_back( wo );
   //   this->setActor( wo ); //Start module where human is the actor
   //}

   //{
   //   //Create and insert the WOWheeledVehicle
   //   std::vector< std::string > wheels;
   //   std::string wheelStr( "../../../shared/mm/models/WOCar1970sBeaterTire.wrl" );
   //   wheels.push_back( wheelStr );
   //   wheels.push_back( wheelStr );
   //   wheels.push_back( wheelStr );
   //   wheels.push_back( wheelStr );
   //   WO* wo = WOCar1970sBeater::New( "../../../shared/mm/models/WOCar1970sBeater.wrl", wheels );
   //   wo->setPosition( Vector( 5, -15, 20 ) );
   //   wo->setLabel( "Car 1970s Beater" );
   //   ((WOODE*)wo)->mass = 200;
   //   worldLst->push_back( wo );
   //   actorLst->push_back( wo );
   //   this->setActor( wo );
   //   netLst->push_back( wo );
   //}
   
   //Make a Dear Im Gui instance via the WOImGui in the engine... This calls
   //the default Dear ImGui demo that shows all the features... To create your own,
   //inherit from WOImGui and override WOImGui::drawImGui_for_this_frame(...) (among any others you need).
   
   WOAnim* current_object;
   
   WOImGui* gui = WOImGui::New( nullptr );
   gui->setLabel( "My Gui" );
   gui->subscribe_drawImGuiWidget(
      [this, gui, &current_object]() //this is a lambda, the capture clause is in [], the input argument list is in (), and the body is in {}
      {
         static int tracker = 0;

         if(woList.size() > 0)
         {
            current_object = (WOAnim*) worldLst->getWOByID(woList[tracker]);
         }
         else
         {
            current_object = nullptr;
         }
      

         static char newLabel[128] = "NewObject";
         
         //Constructor is protected and only invoked by descendants of the GLView class
         //tracks position and angle of currentobect 
         static float xP;
         static float yP;
         static float zP;
         
         

         if(current_object != nullptr)
         {
            xP = current_object->getPosition()[0];
            yP = current_object->getPosition()[1];
            zP = current_object->getPosition()[2];
         
         }
         else
         {
            xP = 0;
            yP = 0;
            zP = 0;
         }

         static float xPAngle = 0.0f;
         static float yPAngle = 0.0f;
         static float zPAngle = 0.0f;
         static float addedX = 0.0f;
         static float addedY = 0.0f;
         static float addedZ = 0.0f;

         static std::string updateText = "";
         static bool globalAngleBool = true;
         static std::string angleChangeLabel = "Global";
         static std::string modelText = "";

          (ImGui::Begin("Animations"));

            if(current_object != nullptr)
               {
                  ImGui::Text(("Current Object: " + current_object->getLabel()).c_str());  
               
               }
               else
               {
                  ImGui::Text(("Current Object: "));  
               }
               ImGui::Separator();
               ImGui::Text((updateText).c_str());
               ImGui::Separator();
            
            // ImGui::Text(std::to_string(current_object->get_aiScene()->mNumAnimations).c_str());
            
            if(ImGui::CollapsingHeader("Testing Info") && current_object != nullptr)
            {

               if(ImGui::Button("Print Mesh Info to File"))
               {
                  // std::string fileTemp = current_object->getModel()->getFileName();

                  current_object->parse_scene();
                  updateText = "Saved animation info to " + current_object->get_filename() + ".txt";
               }

               std::vector<ModelMesh*> temp = current_object->getModel()->getModelDataShared()->getModelMeshes();
               ImGui::Text(("Number of meshes:" + std::to_string(temp.size())).c_str());
               for (int i = 0; i < temp.size(); ++i)
               {
                  ImGui::Text(("Mesh "+ std::to_string(i+1) + ": " + temp.at(i)->getDescription()).c_str());
                  

                  ImGui::Text((temp.at(i)->getMeshDataShared()->toString()).c_str());
                  // temp.at(i)->getWorldOctreeNodeContainingThisMesh()->getNumNodes();
                                    
               }
            }

            if (ImGui::CollapsingHeader("Rotate Model") && current_object != nullptr)
            { 
               // redCube->getPosition()[0];
               
               if(ImGui::SliderFloat("Set X Position", &xP, -100, 100))
               {
                  
                  current_object->setPosition(xP,yP,zP);
                  
               
               }
               
               if(ImGui::SliderFloat("Set Y Position", &yP, -100, 100))
               {
                  
                  current_object->setPosition(xP,yP,zP);
                 
                  
               }

               if(ImGui::SliderFloat("Set Z Position", &zP, -100, 100))
               {
                  
                  current_object->setPosition(xP,yP,zP);

               }
               
               if (ImGui::SliderAngle("Rotate X Position", &xPAngle))
               {
                  
                  if(globalAngleBool)
                     current_object->rotateAboutGlobalX(DEGtoRAD * xPAngle);
                  else
                  {
                     current_object->rotateAboutRelX(DEGtoRAD * xPAngle);
                  }
               }

               if (ImGui::SliderAngle("Rotate Y Position", &yPAngle))
               {
                  if(globalAngleBool)
                     current_object->rotateAboutGlobalY(DEGtoRAD * yPAngle);
                  else
                  {
                     current_object->rotateAboutRelY(DEGtoRAD * yPAngle);
                  }
                 
               }  

               if (ImGui::SliderAngle("Rotate Z Position", &zPAngle))
               {
                  if(globalAngleBool)
                     current_object->rotateAboutGlobalZ(DEGtoRAD * zPAngle);
                  else
                     current_object->rotateAboutRelZ(DEGtoRAD * zPAngle);
                 
               }

               if (ImGui::Button(("Current Angle: "+ angleChangeLabel).c_str()))
               {
                  if(globalAngleBool)
                  {  
                     
                     globalAngleBool = false;
                     angleChangeLabel = "Relative";
                     xPAngle = 0.0f;
                     yPAngle = 0.0f;
                     zPAngle = 0.0f;
                     updateText = "Switched to Relative Rotation";
            
                  }
                  else
                  {
                     globalAngleBool = true;
                     angleChangeLabel = "Global";
                     xPAngle = 0.0f;
                     yPAngle = 0.0f;
                     zPAngle = 0.0f;
                     updateText = "Switched to Global Rotation";
                     
                  } 
               }
            
               if(ImGui::Button("Switch Object"))
               {
                  if(woList.size() > 1)
                  {
                  
                     if(tracker >= (int) woList.size()-1)
                        tracker = 0;
                     else 
                        ++tracker;
                     current_object = (WOAnim*) worldLst->getWOByID(woList[tracker]);
                     updateText = std::string("Switched to ") + current_object->getLabel();
                  }
                  else
                  {
                     updateText = std::string("Cannot switch. ") + current_object->getLabel() + std::string(" is the only object");
                  }
               }
              
            }


            if(ImGui::CollapsingHeader("Detailed Statistics") && current_object != nullptr)
            {
               modelText = "";
               for(unsigned int i = 0; i < 6; ++i)
               {
                  modelText += ("Mesh " + std::to_string(i+1) + ": ");
                  modelText+=( current_object->get_aiScene()->mMeshes[i]->mName.C_Str() );
                  modelText += ("\n");
               }

               ImGui::Separator();
               ImGui::Text("Object Pose");
               ImGui::Separator();
               ImGui::Text((current_object->getPose()).toString().c_str());
               ImGui::Spacing();
               ImGui::Text(modelText.c_str());
            }

            xPAngle = 0;
            yPAngle = 0;
            zPAngle = 0;
          (ImGui::End());
      } );
   this->worldLst->push_back( gui );

   createCS4350_Final_AnimationsWayPoints();
}


void GLViewCS4350_Final_Animations::createCS4350_Final_AnimationsWayPoints()
{
   // Create a waypoint with a radius of 3, a frequency of 5 seconds, activated by GLView's camera, and is visible.
   WayPointParametersBase params(this);
   params.frequency = 5000;
   params.useCamera = true;
   params.visible = true;
   WOWayPointSpherical* wayPt = WOWayPointSpherical::New( params, 3 );
   wayPt->setPosition( Vector( 50, 0, 3 ) );
   worldLst->push_back( wayPt );
}
