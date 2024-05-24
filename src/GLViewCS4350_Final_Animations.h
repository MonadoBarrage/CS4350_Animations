#pragma once

#include "GLView.h"
#include "assimp/Importer.hpp"
#include "assimp/scene.h"
#include "assimp/postprocess.h"
#include <map>
#include <string>
#include <vector>
#include "ogldev_util.h"
#include "WOAnim.h"


namespace Aftr
{
   class Camera;

/**
   \class GLViewCS4350_Final_Animations
   \author Scott Nykl 
   \brief A child of an abstract GLView. This class is the top-most manager of the module.

   Read \see GLView for important constructor and init information.

   \see GLView

    \{
*/

class GLViewCS4350_Final_Animations : public GLView
{
public:
   static GLViewCS4350_Final_Animations* New( const std::vector< std::string >& outArgs );
   virtual ~GLViewCS4350_Final_Animations();
   virtual void updateWorld(); ///< Called once per frame
   virtual void loadMap(); ///< Called once at startup to build this module's scene
   virtual void createCS4350_Final_AnimationsWayPoints();
   virtual void onResizeWindow( GLsizei width, GLsizei height );
   virtual void onMouseDown( const SDL_MouseButtonEvent& e );
   virtual void onMouseUp( const SDL_MouseButtonEvent& e );
   virtual void onMouseMove( const SDL_MouseMotionEvent& e );
   virtual void onKeyDown( const SDL_KeyboardEvent& key );
   virtual void onKeyUp( const SDL_KeyboardEvent& key );

   std::vector<unsigned int> woList;
   Assimp::Importer importer;

protected:
   GLViewCS4350_Final_Animations( const std::vector< std::string >& args );
   virtual void onCreate();   
};

/** \} */

} //namespace Aftr
