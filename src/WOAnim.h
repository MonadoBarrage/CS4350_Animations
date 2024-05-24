// #pragma once
// #ifdef AFTR_CONFIG_USE_ASSIMP

// #include "GLView.h"
// #include "WO.h"

// namespace Aftr
// {
//     class WOAnim
//     {
//         public:
            

//     };

// /** \} */


// }; //namespace Aftr

// #endif
#pragma once
// #include "GLViewCS4350_Assignment_Final.h"
#include "WO.h"
#include <assimp/Importer.hpp>      // C++ importer interface
#include <assimp/scene.h>       // Output data structure
#include <assimp/postprocess.h>
#include <map>
#include <string>
#include <vector>
#include "ogldev_util.h"

#define ASSIMP_LOAD_FLAGS (aiProcess_Triangulate | aiProcess_GenNormals |  aiProcess_JoinIdenticalVertices )
#define MAX_NUM_BONES_PER_VERTEX 4

namespace Aftr {
    struct VertexBoneData
    {
        uint BoneIDs[MAX_NUM_BONES_PER_VERTEX] = { 0 };
        float Weights[MAX_NUM_BONES_PER_VERTEX] = { 0.0f };

        VertexBoneData()
        {
        }

        void AddBoneData(uint BoneID, float Weight, FILE* out)
        {
            for (uint i = 0 ; i < ARRAY_SIZE_IN_ELEMENTS(BoneIDs) ; i++) {
                if (Weights[i] == 0.0) {
                    BoneIDs[i] = BoneID;
                    Weights[i] = Weight;
                    fprintf(out,"bone %d weight %f index %i\n", BoneID, Weight, i);
                    return;
                }
            }

            // should never get here - more bones than we have space for
            assert(0);
        }
    };



    class WOAnim : public WO
    {
        public:
            WOAnim();
            static WOAnim* New(const std::string& path, const Aftr::Vector& scale, Aftr::MESH_SHADING_TYPE mst, std::vector<unsigned int> &tracker, Assimp::Importer &imp);
            const aiScene* get_aiScene();

            void parse_scene();
            std::string get_filename();

        protected:
            
            int get_bone_id(const aiBone* pBone, FILE* out);
            void parse_single_bone(int mesh_index, const aiBone* pBone, FILE* out);
            void parse_mesh_bones(int mesh_index, const aiMesh* pMesh, FILE* out);
            void parse_meshes(FILE* out);

            
            virtual void onCreate(const std::string& path, const Aftr::Vector& scale, Aftr::MESH_SHADING_TYPE mst, std::vector<unsigned int> &tracker, Assimp::Importer &imp);
            
            std::string filename;
            const aiScene* pScene;

            std::vector<VertexBoneData> vertex_to_bones;
            std::vector<int> mesh_base_vertex;
            std::map<std::string,uint> bone_name_to_index_map;
    };

};