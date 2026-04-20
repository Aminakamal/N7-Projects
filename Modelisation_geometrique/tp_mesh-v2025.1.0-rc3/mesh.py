import numpy as np
import trimesh 
from tqdm import tqdm
from ipywidgets import widgets, IntSlider
from IPython.display import display, clear_output
import plotly.graph_objects as go
from utils import *
import meshio
import heapq


class Vertex:
    def __init__(self, x, y, z):
        self.x = x
        self.y = y
        self.z = z
        self.outgoing_half_edge = None  # A reference to one of the outgoing half-edges
        self.distance = float('inf')  # Initializing the distance to infinity
        self.indice = -1
    
    def __lt__(self, other):
        # Comparaison basée sur la distance
        return self.distance < other.distance
class HalfEdge:
    def __init__(self):
        self.vertex = None  # The vertex the half-edge points to
        self.opposite = None    # The twin half-edge
        self.next = None    # The next half-edge around the face
        self.face = None    # The face the half-edge borders
class Face:
    def __init__(self):
        self.halfedge = None  # A reference to one of the half-edges bordering the face
        self.normal = np.zeros((3,1))
class Mesh:
    def __init__(self, num_vertices, num_faces):
        self.vertices = np.empty(num_vertices, dtype=Vertex)  # List of all mesh vertices
        self.half_edges = np.empty(3 * num_faces, dtype=HalfEdge)  # List of all half edges of the mesh
        self.faces = np.empty(num_faces, dtype=Face)  # List of all mesh faces

## Create the above data structure from a file.obj
def create_half_edge_mesh(filename):
    mesh = meshio.read(filename)
    if len(mesh.cells) == 1:
        new_mesh = Mesh(len(mesh.points), len(mesh.cells[0].data))
    else:
        new_mesh = Mesh(len(mesh.points), len(mesh.cells))
    vertices = [Vertex(*v) for v in mesh.points]
    for i in range(len(vertices)):
        vertices[i].indice = i
    half_edges = []
    edge_dict = {}

    for cell in mesh.cells:

        for k in range(len(cell.data)):
            face  = cell.data[k]
            face_half_edges = []
            face_obj = Face()

            for i in range(len(face)):

                #vertices are named
                start_idx = face[i]
                end_idx = face[(i + 1) % len(face)]

            
                #halfedge and its opposite are named
                edge_key = (start_idx, end_idx)
                twin_key = (end_idx, start_idx)

                he = HalfEdge()
                he.vertex = vertices[end_idx]
                he.face = face_obj
                face_half_edges.append(he)
                vertices[start_idx].outgoing_half_edge = he

                # Check if there is an uninitialized opposite halfedge
                if (twin_key in edge_dict):
                    twin_he = edge_dict[twin_key]
                    he.opposite = twin_he
                    twin_he.opposite = he
                    del edge_dict[twin_key]
                else:
                    edge_dict[edge_key] = he

            # Reference update `next'
            for j in range(len(face_half_edges)):
                he = face_half_edges[j]
                next_he = face_half_edges[(j + 1) % len(face_half_edges)]
                he.next = next_he
            
            v2 = np.array([vertices[face[2]].x, vertices[face[2]].y, vertices[face[2]].z])
            v1 = np.array([vertices[face[1]].x, vertices[face[1]].y, vertices[face[1]].z])
            v0 = np.array([vertices[face[0]].x, vertices[face[0]].y, vertices[face[0]].z])
            normal = -np.cross(v2-v0,v1-v0)/np.linalg.norm(np.cross(v2-v0,v1-v0))
            face_obj.normal = np.array(normal)
            face_obj.halfedge = face_half_edges[0]
            half_edges.extend(face_half_edges)
            new_mesh.faces[k] = face_obj

    new_mesh.vertices = np.array(vertices)
    new_mesh.half_edges = np.array(half_edges)

    # Final Edit
    error = False
    nb_error = 0
    for he in half_edges:
        if he.opposite is None:
            nb_error += 1
            if (not error):
                print(f"ERROR : Half-edge {he} with vertex {he.vertex} has no opposite")
                print("Maybe your object is not well defined")
                print("Your object must be a close surface")
                error = not error
    print("number of halfedge",len(new_mesh.half_edges),"number of halfedge error", nb_error)
    return new_mesh


## Creates list of half-edges of a given face
def get_halfedges(face : Face) -> list:
    """
    Finds all half-edges associated with a given face in a half-edge mesh structure.

    Args:
        face (Face): The face for which to find half-edges. This face must be part of a valid
                     HalfEdge mesh structure.

    Returns:
        list[HalfEdge]: A list of `HalfEdge` objects that are associated with the input face.
                        The first half-edge in the list corresponds to the first vertex of the face.
    """
    # TODO
    first_half_edge = face.halfedge
    half_edges = []
    current_half_edge = first_half_edge
    while True:
        half_edges.append(current_half_edge)
        current_half_edge = current_half_edge.next
        if current_half_edge == first_half_edge:
            break
        else:
            continue
    return half_edges


def neighbors_faces(vertex: Vertex) -> list:
    """
    Finds all faces adjacent to a given vertex in a half-edge mesh structure.

    Args:
        vertex (Vertex): The vertex for which to find adjacent faces. This vertex
                         must have its `outgoing_half_edge` attribute correctly
                         set as part of a valid HalfEdge mesh structure.

    Returns:
        list[Face]: A list of `Face` objects that are adjacent to the input vertex.
    """
    first_half_edge = vertex.outgoing_half_edge
    if first_half_edge is None:
        return []

    neighbor_faces = []
    current_half_edge = first_half_edge

    while True:
        if current_half_edge.face is not None:
            neighbor_faces.append(current_half_edge.face)
        if current_half_edge.opposite is None or current_half_edge.opposite.next is None:
            break

        current_half_edge = current_half_edge.opposite.next
        if current_half_edge == first_half_edge:
            break

    return neighbor_faces


def compute_normal(vertex) -> np.ndarray:
    """
    Computes the normal vector of a given vertex by averaging the normals of its neighboring faces.

    Args:
        vertex (Vertex): The vertex for which the normal vector is to be computed.
                         This vertex must be part of a valid half-edge mesh structure.

    Returns:
        numpy.ndarray: A normalized 3D vector (numpy array) representing the computed normal.
                       If the vertex has no neighboring faces, a zero vector is returned.
    """
    computed_normal = np.zeros((3,1))
    neighbor_faces = neighbors_faces(vertex)
    if not neighbor_faces:
        return computed_normal

    for face in neighbor_faces:
        computed_normal += face.normal.reshape((3,1))

    norm = np.linalg.norm(computed_normal)
    if norm == 0:
        return computed_normal

    computed_normal /= norm
    return computed_normal


def find_direct_neighbors(vertex : Vertex) -> list:
    """
    Finds all vertices directly connected by an edge to a given vertex.

    Args:
        vertex (Vertex): The vertex for which to find direct neighbors.
                         This Vertex object must have its `outgoing_half_edge`
                         attribute correctly set as part of a valid HalfEdge mesh structure.

    Returns:
        list[Vertex]: A list containing the Vertex objects that are directly
                      connected to the input `vertex` by an edge.
    """
    direct_neighbors = []
    # ++ # TODO (uncomment the `while` line)
    # First outgoing half-edge
    first_half_edge = vertex.outgoing_half_edge
    if first_half_edge is None:
        return direct_neighbors  # No outgoing half-edge means no neighbors
    # Current half-edge
    current_half_edge = first_half_edge
    # As describe in the figure : find the direct neighbors of the current vertex
    while True:
        # reach the neighboring vertex through the half-edge
            neighboring_vertex = current_half_edge.vertex
        # Add the neighboring vertex to the list
            direct_neighbors.append(neighboring_vertex)

        # Move to the next half-edge outgoing around the current vertex
            if current_half_edge.opposite is None or current_half_edge.opposite.next is None :
                break
            current_half_edge = current_half_edge.opposite.next


        # Stop if we have looped back to the starting half-edge
            if current_half_edge == first_half_edge:
                break


    # Return the list of direct neighbors found
    return direct_neighbors
    


def find_neighbors_of_rank(vertex, rank):
    """
    Finds all vertices that are exactly `rank` edges away from a given vertex.

    Args:
        vertex (Vertex): The starting vertex for which neighbors are to be found.
        rank (int): The rank of the neighbors to find. Must be greater than or equal to 1.

    Returns:
        list[Vertex]: A list of `Vertex` objects that are exactly `rank` edges away
                      from the input `vertex`.
    """

    if rank < 1:
        return []  # Invalid rank means no neighbors can be found.

    # Initialize the queue 
    queue = [(vertex, 0)]  # Each element is a tuple (vertex, depth)
    visited = set()  # Set of visited vertices to avoid cycles
    visited.add(vertex)
    neighbors = []  # List of neighbors found at the specified rank

    # TODO (uncomment the next line)
    while len(queue) != 0:
        # Get and remove the first element from the queue
        current_vertex, current_rank = queue.pop(0)
        
        # If the required rank is reached, add the vertex to the neighbors list
        if current_rank == rank:
            neighbors.append(current_vertex)


        # Otherwise, continue exploring the neighboring vertices
        elif current_rank < rank:
            # As describe in the figure : find the direct neighbors of the curent vertex
            direct_neighbors = find_direct_neighbors(current_vertex)
            for neighbor in direct_neighbors:

                # Check if the neighbor has already been visited
                if neighbor not in visited:

                    # Mark the vertex as visited
                    visited.add(neighbor)

                    # Add to queue with incremented rank
                    queue.append((neighbor, current_rank + 1))


    # Return the list of neighbors found at the given rank
    return neighbors



## Change a vertex in position vector
#a position vector is a numpy array of size (3,1)
def get_position(vertex):
    return np.array([vertex.x, vertex.y, vertex.z])


#compute distance between two vertices
def get_distance(vertex1, vertex2):
    a1 = get_position(vertex1)
    a2 = get_position(vertex2)
    a = a2 - a1
    return np.sqrt(np.dot(a,a))


################ OPTIONAL 
# Finds all vertices directly connected by an edge to a given vertex.
# Args:
#     vertex (Vertex): The vertex for which to find direct neighbors.
#                     This Vertex object must have its `outgoing_half_edge`
#                     attribute correctly set as part of a valid HalfEdge mesh structure.
#                     (Note: The parameter name 'nsommets' in the original code
#                     is potentially misleading; it refers to a single vertex).
# Returns:
#     list[Vertex]: A list containing the Vertex objects that are
#                 directly connected to the input `vertex` by an edge.
def get_direct_neighbors(nsommets):
    voisins = []

    demi_arete_initiale = nsommets.outgoing_half_edge
    demi_arete_actuelle = demi_arete_initiale

    while True:
        voisin = demi_arete_actuelle.vertex
        voisins.append(voisin)
        
        demi_arete_actuelle = demi_arete_actuelle.opposite.next 
        
        if demi_arete_actuelle == demi_arete_initiale:
            break

    return voisins


def dijkstra(mesh : Mesh, start : Vertex, w : str) -> tuple:
    """
    Calculates the shortest paths from a starting vertex to all other vertices
    in a mesh using Dijkstra's algorithm.

    Args:
        mesh (Mesh): The half-edge mesh structure containing vertices and connectivity information.
        start (Vertex): The starting vertex for calculating distances.
        w (str): The weighting scheme for edges.
            - "one": Each edge has a weight of 1 (counts edges).
            - "dist": Edge weight is the geometric distance between vertices.

    Returns:
        tuple: A tuple containing:
            - distances (dict): A dictionary mapping each Vertex object to its shortest
              calculated distance from the `start` vertex.
            - previous_nodes (dict): A dictionary mapping each Vertex object to its
              predecessor Vertex on the shortest path from `start`. The predecessor of `start` is None.
    """
    # Determine edge weight calculation method
    if w == "one":
        weight_func = lambda u, v: 1  # Use weight 1 for edge count
    elif w == "dist":
        weight_func = lambda u, v: get_distance(u, v) # Use geometric distance
    else:
        raise ValueError("Weight type 'w' must be 'one' or 'dist'")

    # Initialize distances: infinite for all nodes, 0 for the start node
    distances = {node: float('inf') for node in mesh.vertices}
    distances[start] = 0

    # Initialize predecessors: None for all nodes initially
    previous_nodes = {node: None for node in mesh.vertices}

    # Initialize priority queue with (distance, node). Start with the source node.
    # heapq implements a min-heap, keeping the node with the smallest distance at the top.
    priority_queue = [(0, start)]

    # TODO (uncomment the `while` line)
    # Main Dijkstra loop: continues as long as there are nodes to visit
    while priority_queue:
        # Get the node with the smallest distance from the priority queue
        current_distance, current_node = heapq.heappop(priority_queue)

        # Optimization: If we found a shorter path already, skip this entry
        if current_distance > distances[current_node]:
            continue

        # Explore neighbors of the current node
        neighbors = find_direct_neighbors(current_node)
        for neighbor in neighbors:
            # Calculate the weight of the edge to the neighbor
            edge_weight = weight_func(current_node, neighbor)
            
            # Calculate distance to neighbor through current_node
            new_distance = current_distance + edge_weight

            # Relaxation step: If a shorter path to neighbor is found...
            if new_distance < distances[neighbor]:
                # ...update the shortest distance for the neighbor
                distances[neighbor] = new_distance
                # ...update the predecessor of the neighbor
                previous_nodes[neighbor] = current_node
                # ...add/update the neighbor in the priority queue with the new distance
                heapq.heappush(priority_queue, (new_distance, neighbor))

    # Return the calculated shortest distances and the predecessor map
    return distances, previous_nodes


def shortest_path(graph, start, end, w):
    distances, previous_nodes = dijkstra(graph, start, w=w)

    if start != end and distances[end] == float('inf'):
        return [], float('inf')

    path = []
    current_node = end
    
    while current_node is not None:
        path.append(current_node)
        current_node = previous_nodes[current_node]
    
    path = path[::-1]  # Inverser le chemin pour obtenir l'ordre correct
    return path, distances[end]
    
    
##################### Display Launch ###############################
######## DO NOT MODIFY #################

#Show function result 
def display_normals(X, Y, Z, normals, scale=1, percent=100):
    # Create the surface plot
    surface = go.Scatter3d(
        x=X,
        y=Y,
        z=Z,
        mode='markers',
        marker=dict(size=2, opacity=0.7)
    )

    # Create the lines for normals
    lines = []
    n_points = min(len(X), len(Y), len(Z), len(normals))
    step = max(1, int(np.round(100 / max(percent, 1))))
    for i in range(0, n_points, step):
        normal = np.asarray(normals[i]).reshape(-1)
        if normal.size < 3:
            continue
        x_start, y_start, z_start = X[i], Y[i], Z[i]
        x_end = x_start + scale * normal[0]
        y_end = y_start + scale * normal[1]
        z_end = z_start + scale * normal[2]
        lines.append(go.Scatter3d(
            x=[x_start, x_end],
            y=[y_start, y_end],
            z=[z_start, z_end],
            mode='lines',
            line=dict(color='red', width=4),
            showlegend=False
        ))

    # Create the figure and add both surface and lines
    fig = go.Figure(data=[surface] + lines)

    # Update layout for better visualization
    fig.update_layout(
        scene=dict(
            xaxis=dict(title='X'),
            yaxis=dict(title='Y'),
            zaxis=dict(title='Z')
        )
    )

    return fig

#Create a slider for the display function
def normal_slider(X, Y, Z, normals, scale=1):
    slider = IntSlider(min=1, max=100, step=1, value=1, description='Percent')
    output = widgets.Output()

    def update_graph(change=None):
        with output:
            clear_output(wait=True)
            display(display_normals(X, Y, Z, normals, scale, slider.value))

    slider.observe(update_graph, names='value')
    update_graph()
    display(slider, output)

liste_couleurs = ['blue', 'cyan', 'green', 'magenta', 'red', 'yellow']

#Create a function to display vertex neighbors
def display_neighbors(X, Y, Z, i, vertex, scale, percent=100):
    # Create the surface plot
    if i != 0 :
        surface = go.Surface(
            x=X,
            y=Y,
            z=Z,
            showscale=False
        )

        neighbors = find_neighbors_of_rank(vertex, i)
        x = [neighbor.x for neighbor in neighbors]
        y = [neighbor.y for neighbor in neighbors]
        z = [neighbor.z for neighbor in neighbors]
    
        # Mettre à jour la figure en ajoutant les nouveaux voisins et en réaffichant le vertex
        lines = go.Scatter3d(
            x=x,
            y=y,
            z=z,
            mode='markers',
            marker=dict(
                size=3,
                color= liste_couleurs[i%len(liste_couleurs)],
                opacity=0.8,
                showscale=False
            ),
            name='Voisins de rang ' + str(i),
        )
        fig = go.Figure(data=[surface] + [lines])
    else : 
        fig = go.Figure()
        fig.add_trace(go.Scatter3d(
            x=[vertex.x],
            y=[vertex.y],
            z=[vertex.z],
            mode='markers',
            marker=dict(
                size=10,
                color='red',
                opacity=0.8,
                showscale=False
            ),
            name='Vertex sélectionné'
        ))
            
    return fig

#Allow user to easily change neighborhood rank on display
def neighbors_slider(X, Y, Z, vertex, filename, scale):
    slider = IntSlider(min=0, max=20, step=1, value=1, description='rank')
    output = widgets.Output()

    def update_graph(change=None):
        percent = slider.value
        new_fig = []
        for i in range(percent+1):
            new_fig.append(display_neighbors(X, Y, Z, i, vertex, scale, percent=percent))
        new_fig2 = display_wireframe(filename)
        composed = go.Figure()
        for i in range(len(new_fig)):
            composed.add_traces(new_fig[i].data)
        composed.add_traces(new_fig2.data)
        if len(new_fig) > 0:
            composed.update_layout(new_fig[0].layout)

        with output:
            clear_output(wait=True)
            display(composed)

    slider.observe(update_graph, names='value')
    update_graph()
    display(slider, output)
