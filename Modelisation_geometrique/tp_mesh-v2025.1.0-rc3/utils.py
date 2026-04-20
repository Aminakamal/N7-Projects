import numpy as np
from sklearn.decomposition import PCA
from matplotlib import cm
import matplotlib.pyplot as plt
import meshio
import plotly.graph_objs as go
import trimesh

color = ['red','green','blue']

class Vertex:
    def __init__(self, x, y, z):
        self.x = x
        self.y = y
        self.z = z
        self.outgoing_half_edge = None  # A reference to one of the outgoing half-edges
        self.distance = float('inf')  # Initialisation de la distance à l'infini
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


#### Display the . obj as a Wireframe
def display_wireframe(filename, meshvertex = False):
    mesh = trimesh.load(filename)

    # Extract vertices and faces
    vertices = mesh.vertices
    faces = mesh.faces

    # Extract edges from faces
    edges = set()
    for face in faces:
        for i in range(3):
            edge = tuple(sorted([face[i], face[(i + 1) % 3]]))
            edges.add(edge)

    # Prepare data for edges
    edge_x = []
    edge_y = []
    edge_z = []
    for edge in edges:
        edge_x.extend([vertices[edge[0]][0], vertices[edge[1]][0], None])
        edge_y.extend([vertices[edge[0]][1], vertices[edge[1]][1], None])
        edge_z.extend([vertices[edge[0]][2], vertices[edge[1]][2], None])

    # Create a 3D plot with Plotly
    fig = go.Figure(data=[
        go.Scatter3d(
            x=edge_x,
            y=edge_y,
            z=edge_z,
            mode='lines',
            line=dict(color='black', width=.2),
            name='wireframe'
        )
    ])

    # Update layout for better visualization
    fig.update_layout(
        scene=dict(
            xaxis=dict(visible=False),
            yaxis=dict(visible=False),
            zaxis=dict(visible=False)
        ),
        margin=dict(r=0, l=0, b=0, t=0)
    )

    # Show the plot
    
    return fig


def make_pca(data: np.ndarray, origin: np.ndarray, n_components: int):
    """
    Compute the PCA on the data provided
    :param n_components: n_components for the PCA
    :param data: Array containing data
    :return: projection of data 
    """
    x = np.vstack((np.array(data), origin))
    xc = x - origin
    #xc = xc.to_numpy()
    pca = PCA(n_components=n_components)
    pca.fit(xc)
    w = pca.components_
    new_coord = xc @ np.transpose(w)
    return new_coord

def lstsq_quadrics_fitting(pos_xyz):
    """
    Fit a given set of 3D points (x, y, z) to a quadrics of equation ax^2 + by^2 + cxy + dx + ey + f = z
    :param pos_xyz: A two-dimensional numpy array, containing the coordinates of the points
    :return:
    """
    ## Quadric equation
    A = np.ones((pos_xyz.shape[0], 6))
    A[:, 0:2] = pos_xyz[:, 0:2] * pos_xyz[:, 0:2]
    A[:, 2] = pos_xyz[:, 0] * pos_xyz[:, 1]
    A[:, 3:5] = pos_xyz[:, 0:2]
    ## Z-axis
    Z = pos_xyz[:, 2]
    ## coefficents of the quatrics equation
    X, _, _, _ = np.linalg.lstsq(A, Z, rcond=None)
    ## error
    residuals = Z - A @ X
    ## Erreur associée à l'origine est âr construction en dernière position
    error_origin = residuals[-1]
    return X, error_origin


def generate_colormap(distances: np.ndarray, c_type: str):
    """
    Generates a colormap according to the values contained in distances
    :param distances: a numpy.ndarray containing data from which create a colormap
    :param c_type: the type of colormap, it's a matplotlib colormap type
    :return:
    """
    colormap = []
    q25 = np.percentile(distances, 25)
    q75 = np.percentile(distances, 75)
    iqr = q75-q25

    min_dist = np.min(distances)
    max_dist = np.max(distances)
    normed_dist = distances / (q75 + 1.5*iqr)
    col = plt.get_cmap(c_type, 256)
    if min_dist != max_dist:
        for dist in normed_dist:
            if dist < (q25-1.5*iqr)/(q75 + 1.5*iqr) or dist > 1:
                #colormap.append([255, 0, 255])
                colormap.append([1, 0, 1])
            else:
                #colormap.append([255 * i for i in col(float(dist))])
                colormap.append([i for i in col(float(dist))])
    else:
        print("Error")
        n = len(distances)
        #colormap = n * [[0, 255, 0]]
        colormap = n * [[0, 1, 0]]
    return colormap

def generate_colormap2(distances: np.ndarray, c_type: str = 'jet'):
    """
    Generates a colormap according to the values contained in distances
    :param distances: a numpy.ndarray containing data from which create a colormap
    :param c_type: the type of colormap, it's a matplotlib colormap type
    :return:
    """
    colormap = []
    min_dist = np.min(distances)
    max_dist = np.max(distances)
    normed_dist = (distances - min_dist) / (max_dist - min_dist)
    col = cm.get_cmap(c_type, 256)
    if min_dist != max_dist:
        for dist in normed_dist:
            colormap.append([i for i in col(float(dist))])
    return colormap


def print_half_edge(start_point_list, end_point_list):
    # Create 3D Figure
    fig = go.Figure()


    for i in range(len(start_point_list)):
        start_point = start_point_list[i]
        end_point = end_point_list[i]
    # Added scatter3d trace for start and finish points
        fig.add_trace(go.Scatter3d(
            x=[start_point[0], end_point[0]],
            y=[start_point[1], end_point[1]],
            z=[start_point[2], end_point[2]],
            mode='markers+lines',
            line=dict(color='black', width=2),
            marker=dict(size=.5, color='black'),
            name='Line'
        ))

        # Added arrow annotation with cone trace
        fig.add_trace(go.Cone(
            x=[end_point[0]-(end_point[0] - start_point[0])*0.2],
            y=[end_point[1]-(end_point[1] - start_point[1])*0.2],
            z=[end_point[2]-(end_point[2] - start_point[2])*0.2],
            u=[end_point[0] - start_point[0]],
            v=[end_point[1] - start_point[1]],
            w=[end_point[2] - start_point[2]],
            sizeref=0.2,
            anchor="tail",
            showscale=False,
            name='Arrow',
            colorscale=[[0, color[i%3]], [1, color[i%3]]]
        ))

        # Update layout
        

    return fig

def display_neighbors_faces(vertex,list_he):
    fig = go.Figure()
    start_point_list = [[he.opposite.vertex.x,he.opposite.vertex.y,he.opposite.vertex.z] for he in list_he]
    end_point_list = [[he.vertex.x,he.vertex.y,he.vertex.z] for he in list_he]

    fig2 = print_half_edge(start_point_list, end_point_list)
    fig.add_traces(fig2.data)
    fig.add_traces(go.Scatter3d(x=[vertex.x],y=[vertex.y],z=[vertex.z], marker=dict(
            size=2)))
    return fig


def afficher_subplot(fig, filename, _row_, _col_, color, colorscale, colorbar_title, colorbar_x,cmin = -1, cmax = 1, reverscale=False):
    # Load a Trimesh from an OBJ file
    mesh1 = trimesh.load_mesh(filename)

    # Extract coordinates of vertices and indices of faces
    x, y, z = mesh1.vertices[:, 0], mesh1.vertices[:, 1], mesh1.vertices[:, 2]
    i, j, k = mesh1.faces[:, 0], mesh1.faces[:, 1], mesh1.faces[:, 2]

    # Create Plotly figure for 3D mesh
    fig.add_trace(
        go.Mesh3d(
            x=x, y=y, z=z,
            i=i, j=j, k=k,
            intensity=color,  # Use the 'color' values for the color
            colorscale=colorscale,
            flatshading=True,  # Enable flat shading for smoother surfaces
            colorbar=dict(
                title=colorbar_title,
                x=colorbar_x
            ),
            
            cmin = cmin,
            cmax = cmax,
            reversescale=reverscale
        ), row=_row_, col=_col_)

    # Configure axis and title of graph
    fig.update_layout(
        scene=dict(
            xaxis=dict(title='X'),
            yaxis=dict(title='Y'),
            zaxis=dict(title='Z'),
        ),
        title='Trimesh 3D avec Plotly'
    )

### display the list of vertices of shortest path between path[0] et path[-1]
def show_path(path):
    x = [vertex.x for vertex in path]
    y = [vertex.y for vertex in path]
    z = [vertex.z for vertex in path]
    fig = go.Figure()
    fig.add_trace(go.Scatter3d(x=x, y=y, z=z,
                            mode='markers+lines',
                            marker=dict(size=5, color='blue'),
                            line=dict(color='blue', width=2),
                            name="Plus court chemin"))

    # Highlight the first point
    fig.add_trace(go.Scatter3d(x=[x[0]], y=[y[0]], z=[z[0]],
                            mode='markers',
                            marker=dict(size=10, color='green'),
                            name='Premier point'))

    # Highlight the last point
    fig.add_trace(go.Scatter3d(x=[x[-1]], y=[y[-1]], z=[z[-1]],
                            mode='markers',
                            marker=dict(size=10, color='red'),
                            name='Dernier point'))
    return fig