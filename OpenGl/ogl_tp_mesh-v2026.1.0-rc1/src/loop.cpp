/**
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */

#include "loop.hpp"
#include "geometry.hpp"

#include <cassert>

/**
 * Compute the subdivision of the input mesh by applying one step of the Loop algorithm
 *
 * @param[in] origVert The list of the input vertices
 * @param[in] origMesh The input mesh (the vertex indices for each face/triangle)
 * @param[out] destVert The list of the new vertices for the subdivided mesh
 * @param[out] destMesh The new subdivided mesh (the vertex indices for each face/triangle)
 * @param[out] destNorm The new list of normals for each new vertex of the subdivided mesh
 */
void loopSubdivision(const std::vector<point3d>& origVert, //!< the original vertices
                     const std::vector<face>& origMesh,    //!< the original mesh
                     std::vector<point3d>& destVert,       //!< the new vertices
                     std::vector<face>& destMesh,          //!< the new mesh
                     std::vector<vec3d>& destNorm)         //!< the new normals
{
    // copy the original vertices in destVert
    destVert = origVert;

    // start fresh with the new mesh
    destMesh.clear( );

    //    PRINTVAR(destVert);
    //    PRINTVAR(origVert);

    // create a list of the new vertices created with the reference to the edge
    EdgeList newVertices;

    //*********************************************************************
    // for each face
    //*********************************************************************
    for (const auto &f : origMesh )
    {
        //*********************************************************************
        // get the indices of the triangle vertices
        //*********************************************************************
        const auto v1 = f.v1;
        const auto v2 = f.v2;
        const auto v3 = f.v3;



        //*********************************************************************
        // for each edge get the index of the vertex of the midpoint using getNewVertex
        //*********************************************************************
        const auto a = getNewVertex( edge( v1, v2 ), destVert, origMesh, newVertices );
        const auto b = getNewVertex( edge( v2, v3 ), destVert, origMesh, newVertices );
        const auto c = getNewVertex( edge( v3, v1 ), destVert, origMesh, newVertices );



        //*********************************************************************
        // create the four new triangles
        // BE CAREFUL WITH THE VERTEX ORDER!!
        //               v2
        //               /\
        //              /  \
        //             /    \
        //            a ---- b
        //           / \     /\
        //          /   \   /  \
        //         /     \ /    \
        //        v1 ---- c ---- v3
        //
        // the original triangle was v1-v2-v3, use the same clock-wise order for the other
        // hence v1-a-c, a-b-c and so on
        //*********************************************************************
        face f1 = {v1, a, c};
        face f2 = {a, v2, b};
        face f3 = {c, b, v3};
        face f4 = {a, b, c};

        destMesh.push_back(f1);
        destMesh.push_back(f2);
        destMesh.push_back(f3);
        destMesh.push_back(f4);




    }

    //*********************************************************************
    // Update each "old" vertex using the Loop coefficients. A smart way to do
    // so is to think in terms of faces than the single vertex: for each face
    // we update each of the 3 vertices using the Loop formula wrt the other 2 and
    // sum it to a temporary copy tmp of the vertices (which is initialized to
    // [0 0 0] at the beginning). We also keep a record of the occurrence of each vertex.
    // At then end, to get the final vertices we just need to divide each vertex
    // in tmp by its occurrence
    //*********************************************************************

    // A list containing the occurrence of each vertex
    std::vector<size_t> occurrences( origVert.size( ), 0 );

    // A list of the same size as origVert with all the elements initialized to [0 0 0]
    std::vector<point3d> tmp( origVert.size( ) );

    //*********************************************************************
    // for each face
    //*********************************************************************
    for ( const auto &face : origMesh )
    {
        //*********************************************************************
        // consider each of the 3 vertices:
        // 1) increment its occurrence
        // 2) apply Loop update wrt the other 2 vertices of the face
        // BE CAREFUL WITH THE COEFFICIENT OF THE OTHER 2 VERTICES!... consider
        // how many times each vertex is summed in the general case...
        //*********************************************************************

        // Vertex 1
        occurrences[face.v1]++;
        tmp[face.v1] += 0.5f * (origVert[face.v2] + origVert[face.v3]);

        // Vertex 2
        occurrences[face.v2]++;
        tmp[face.v2] += 0.5f * (origVert[face.v3] + origVert[face.v1]);

        // Vertex 3
        occurrences[face.v3]++;
        tmp[face.v3] += 0.5f * (origVert[face.v1] + origVert[face.v2]);




    }

    //*********************************************************************
    //  To obtain the new vertices, divide each vertex by its occurrence value
    //*********************************************************************
    for (size_t i = 0; i < origVert.size( ); ++i )
    {
        assert( occurrences[i] != 0 );
        destVert[i] = (5.f / 8.f) * origVert[i] + (3.f / 8.f) * (tmp[i] * (1.f / occurrences[i]));

    }
    //PRINTVAR(destVert);

    // redo the normals, reset and create a list of normals of the same size as
    // the vertices, each normal set to [0 0 0]
    destNorm.clear( );
    destNorm = std::vector<vec3d>(destVert.size( ));

    //*********************************************************************
    //  Recompute the normals for each face
    //*********************************************************************
    for ( const auto &face : destMesh )
    {
        //*********************************************************************
        //  Calculate the normal of the triangles, it will be the same for each vertex
        //*********************************************************************
        vec3d faceNorm = computeNormal(destVert[face.v1], destVert[face.v2], destVert[face.v3]);

        //*********************************************************************
        // Sum the normal of the face to each vertex normal using the angleAtVertex as weight
        //*********************************************************************
        destNorm[face.v1] += faceNorm * angleAtVertex(destVert[face.v1], destVert[face.v2], destVert[face.v3]);
        destNorm[face.v2] += faceNorm * angleAtVertex(destVert[face.v2], destVert[face.v3], destVert[face.v1]);
        destNorm[face.v3] += faceNorm * angleAtVertex(destVert[face.v3], destVert[face.v1], destVert[face.v2]);


    }
    //*********************************************************************
    // normalize the normals of each vertex
    //*********************************************************************
    for (auto &norm : destNorm)
    {
        norm.normalize();
    }


}

/**
 * For a given edge it returns the index of the new vertex created on its middle point.
 * If such vertex already exists it just returns the its index; if it does not exist
 * it creates it in vertList along it's normal and return the index
 *
 * @param[in] e the edge
 * @param[in,out] vertList the list of vertices
 * @param[in] mesh the list of triangles
 * @param[in,out] newVertList The list of the new vertices added so far
 * @return the index of the new vertex or the one that has been already created for that edge
 * @see EdgeList
 */
idxtype getNewVertex(const edge& e,
                     std::vector<point3d>& vertList,
                     const std::vector<face>& mesh,
                     EdgeList& newVertList)
{
        PRINTVAR(e);
    //    PRINTVAR(newVertList);

    //*********************************************************************
    // if the egde is NOT contained in the new vertex list (see EdgeList.contains() method)
    //*********************************************************************
    if ( !newVertList.contains( e ) )
    {
        //*********************************************************************
        // generate new index (vertex.size)
        //*********************************************************************
        idxtype newVertIdx = vertList.size();

        //*********************************************************************
        // add the edge and index to the newVertList
        //*********************************************************************
        newVertList.add(e, newVertIdx);

        // generate new vertex
        point3d nvert;        //!< this will contain the new vertex
        idxtype oppV1;        //!< the index of the first "opposite" vertex
        idxtype oppV2;        //!< the index of the second "opposite" vertex (if it exists)

        //*********************************************************************
        // check if it is a boundary edge, ie check if there is another triangle
        // sharing this edge and if so get the index of its "opposite" vertex
        //*********************************************************************
        if ( !isBoundaryEdge( e, mesh, oppV1, oppV2 ) )
        {
            // if it is not a boundary edge create the new vertex

            //*********************************************************************
            // the new vertex is the linear combination of the two extrema of
            // the edge V1 and V2 and the two opposite vertices oppV1 and oppV2
            // Using the loop coefficient the new vertex is
            // nvert = 3/8 (V1+V2) + 1/8(oppV1 + oppV2)
            //
            // REMEMBER THAT IN THE CODE OPPV1 AND OPPV2 ARE INDICES, NOT VERTICES!!!
            //*********************************************************************
            nvert = ( (3.f / 8.f) * (vertList[e.first] + vertList[e.second]) + (1.f / 8.f) * (vertList[oppV1] + vertList[oppV2]) );

        }
//         else
        {
            //*********************************************************************
            // otherwise it is a boundary edge then the vertex is the linear combination of the
            // two extrema
            //*********************************************************************
            nvert = 0.5f * (vertList[e.first] + vertList[e.second]);
        }
        //*********************************************************************
        // append the new vertex to the list of vertices
        //*********************************************************************
        vertList.push_back(nvert);

        //*********************************************************************
        // return the index of the new vertex
        //*********************************************************************
        return newVertIdx;
    }
    else
    // else we don't need to do anything, just return the associated index of the
    // already existing vertex
    {
        //*********************************************************************
        // get and return the index of the vertex
        //*********************************************************************
        return newVertList.getIndex( e );
    }

    // this is just to avoid compilation errors at the beginning
    // execution should normally never reach here
    // the return instructions go inside each branch of the if - else above
    // remove this return instruction once you have implemented the function
    std::cerr << "WARNING: the subdivision may not be implemented correctly" << std::endl;
    return 0;
}