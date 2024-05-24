#include "WOAnim.h"

using namespace Aftr;


WOAnim::WOAnim() : IFace(this)
{
    pScene = nullptr;
}

WOAnim* WOAnim::New(const std::string& path, const Aftr::Vector& scale, Aftr::MESH_SHADING_TYPE mst, std::vector<unsigned int> &tracker,Assimp::Importer &imp)
{
    WOAnim* wo = new WOAnim();
    wo->onCreate(path,scale,mst, tracker,imp);
    return wo;
}

void WOAnim::onCreate(const std::string& path, const Aftr::Vector& scale, Aftr::MESH_SHADING_TYPE mst, std::vector<unsigned int> &tracker,Assimp::Importer &imp)
{
    
    WO::onCreate(path,scale,mst);
    filename = path;
    pScene = imp.ReadFile(path, ASSIMP_LOAD_FLAGS);
    tracker.push_back(this->getID());
}

const aiScene* WOAnim::get_aiScene()
{
    
    return pScene;
}

std::string WOAnim::get_filename()
{
    return filename;
}



int WOAnim::get_bone_id(const aiBone* pBone, FILE* out)
{
    int bone_id = 0;
    std::string bone_name(pBone->mName.C_Str());

    if (bone_name_to_index_map.find(bone_name) == bone_name_to_index_map.end()) {
        // Allocate an index for a new bone
        bone_id = (int)bone_name_to_index_map.size();
        bone_name_to_index_map[bone_name] = bone_id;
    }
    else {
        bone_id = bone_name_to_index_map[bone_name];
    }

    return bone_id;
}

void WOAnim::parse_single_bone(int mesh_index, const aiBone* pBone, FILE* out)
{
    fprintf(out, "      Bone '%s': num vertices affected by this bone: %d\n", pBone->mName.C_Str(), pBone->mNumWeights);

    int bone_id = get_bone_id(pBone, out);
    fprintf(out, "bone id %d\n", bone_id);

    for (unsigned int i = 0 ; i < pBone->mNumWeights ; i++) {
        if (i == 0) fprintf(out, "\n");
        const aiVertexWeight& vw = pBone->mWeights[i];
      try
      {
         
      
        uint global_vertex_id = mesh_base_vertex[mesh_index] + vw.mVertexId;
        fprintf(out, "Vertex id %d ", global_vertex_id);

        assert(global_vertex_id < vertex_to_bones.size());
        vertex_to_bones[global_vertex_id].AddBoneData(bone_id, vw.mWeight,out);
        }
      catch(exception e)
      {
         cout << "CONNETTEFEKE";
      }
    }

    fprintf(out, "\n");
}

void WOAnim::parse_mesh_bones(int mesh_index, const aiMesh* pMesh, FILE* out)
{
    for (unsigned int i = 0 ; i < pMesh->mNumBones ; i++) {
        parse_single_bone(mesh_index, pMesh->mBones[i],out);
    }
}

void WOAnim::parse_meshes(FILE* out)
{
    fprintf(out, "*******************************************************\n");
    fprintf(out, "Parsing %d meshes\n\n", pScene->mNumMeshes);

    int total_vertices = 0;
    int total_indices = 0;
    int total_bones = 0;

    mesh_base_vertex.resize(pScene->mNumMeshes);

    for (unsigned int i = 0 ; i < pScene->mNumMeshes ; i++) {        const aiMesh* pMesh = pScene->mMeshes[i];
        int num_vertices = pMesh->mNumVertices;
        int num_indices = pMesh->mNumFaces * 3;
        int num_bones = pMesh->mNumBones;
        mesh_base_vertex[i] = total_vertices;
        fprintf(out,"  Mesh %d '%s': vertices %d indices %d bones %d\n\n", i, pMesh->mName.C_Str(), num_vertices, num_indices, num_bones);
        total_vertices += num_vertices;
        total_indices  += num_indices;
        total_bones += num_bones;

        vertex_to_bones.resize(total_vertices);

        if (pMesh->HasBones()) {
            parse_mesh_bones(i, pMesh,out);
        }

        fprintf(out,"\n");
    }

    fprintf(out,"\nTotal vertices %d total indices %d total bones %d\n", total_vertices, total_indices, total_bones);
}

void WOAnim::parse_scene()
{
   std::string temp = filename + ".txt";
   FILE* output_file = fopen(temp.c_str(), "w");
   parse_meshes(output_file);
}

