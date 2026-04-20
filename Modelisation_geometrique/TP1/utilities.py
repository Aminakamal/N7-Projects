from math import *
import random as rd
import matplotlib.pyplot as plt
import seaborn as sns
import numpy as np
from matplotlib.animation import FuncAnimation
import ipywidgets as widgets
from IPython.display import display
import plotly.graph_objects as go
from plotly.subplots import make_subplots
from IPython.display import clear_output
from tqdm import tqdm
from approximation import *
import time
from scipy import stats
from ipywidgets import interact, IntSlider
import ipywidgets as widgets

from time import time


### Global variable Interpolation
borne_max = 1000
epsilon = 1.0 / 10
liste_couleurs = ['blue', 'cyan', 'green', 'magenta', 'red', 'yellow']


### Generate a set of points without ambiguity of the abscissas
def generate_points(nb_pts, b_max=borne_max):
    X = [np.round(i, 2) / (borne_max) for i in np.random.randint(b_max, size=(nb_pts))]
    Y = [np.round(i, 2) / (borne_max) for i in np.random.randint(b_max, size=(nb_pts))]
    # Verification: No double abscissas 
    # while (len(list(pd.Series(X).value_counts().to_dict().values())) != nb_pts):
    #    X = [np.round(i,2)/(borne_max) for i in np.random.randint(b_max, size=(nb_pts))]
    return X, Y


###################################################################################################################
################################################## Approximation ##################################################
###################################################################################################################

def estimate_line(n_values, times):
    slope, intercept, _, _, _ = stats.linregress(n_values, times)
    return slope, intercept


def extrapolate(slope, intercept, max_n):
    extrapolated_n_values = np.linspace(0, max_n, 100)
    extrapolated_times = slope * extrapolated_n_values + intercept
    return extrapolated_n_values, extrapolated_times


def estimate_quadratic(n_values, times):
    coeffs = np.polyfit(n_values, times, 2)
    return coeffs


def extrapolate_quadratic(coeffs, max_n):
    a, b, c = coeffs
    extrapolated_n_values = np.linspace(0, max_n, 100)
    extrapolated_times = a * extrapolated_n_values ** 2 + b * extrapolated_n_values + c
    return extrapolated_n_values, extrapolated_times


def compare_temps_1(debut, fin, pas, nb_echantillon):
    tempsbernstein = []
    tempscasteljau = []
    tempscasteljausub = []
    list_t = generate_samples(nb_samples=nb_echantillon)
    for i in tqdm(range(debut, fin, pas)):
        nb_pts_controle = i
        X_pts_controles, Y_pts_controles = generate_points(nb_pts_controle)

        t1 = time()
        liste_points = bezier_bernstein(X_pts_controles, Y_pts_controles, list_t)
        liste_points = np.array(liste_points)
        t2 = time()
        tempsbernstein.append(t2 - t1)

        t1 = time()
        liste_points = []
        for tt in list_t:
            # Approximation of the abscissas
            x = de_casteljau(X_pts_controles, tt)
            # Approximation of the ordinates
            y = de_casteljau(Y_pts_controles, tt)
            liste_points.append([x, y])
        t2 = time()
        tempscasteljau.append(t2 - t1)

    for i in tqdm(np.logspace(1, 10, num=10)):
        nb_pts_controle = i
        t1 = time()
        nb_subdivision = np.round(np.log(nb_echantillon / nb_pts_controle) / np.log(2))

        (X_subdivision, Ysubdivision) = de_casteljau_subdivision(X_pts_controles, Y_pts_controles, nb_subdivision)
        t2 = time()
        tempscasteljausub.append(t2 - t1)
        print(nb_subdivision)

    bernstein_coeffs = estimate_quadratic(range(debut, fin, pas), tempsbernstein)
    casteljau_slope, casteljau_intercept = estimate_line(range(debut, fin, pas), tempscasteljau)
    casteljausub_slope, casteljausub_intercept = estimate_line(range(debut, fin, pas), tempscasteljau)

    extra_casteljausub_n_values, extra_casteljausub_times = extrapolate(casteljausub_slope, casteljausub_intercept, fin)
    extra_casteljau_n_values, extra_casteljau_times = extrapolate(casteljau_slope, casteljau_intercept, fin)
    extra_bernstein_n_values, extra_bernstein_times = extrapolate_quadratic(bernstein_coeffs, fin)

    plt.figure()

    plt.plot(range(debut, fin, pas), tempsbernstein, color='red', label='Bernstein')
    plt.plot(extra_bernstein_n_values, extra_bernstein_times, label='Bernstein (extrapolated)', linestyle='-',
             color='red', alpha=0.5)
    plt.plot(range(debut, fin, pas), tempscasteljau, color='blue', label='Casteljau')
    plt.plot(extra_casteljau_n_values, extra_casteljau_times, label='Casteljau (extrapolated)', linestyle='-',
             color='blue', alpha=0.5)
    plt.legend()
    plt.xlabel('number of control points')
    plt.ylabel('calculation time')

    plt.show()

    fig, ax = plt.subplots()
    print(tempscasteljausub)

    plt.plot(np.logspace(1, 10, num=len(tempscasteljausub)), tempscasteljausub, color='green', label='Casteljau Subdivision')
    plt.legend()
    plt.xlabel('number of subdivisions')
    plt.ylabel('calculation time')

    plt.show()


def compare_temps_2(debut, fin, pas, nb_pts_controle):
    X_pts_controles, Y_pts_controles = generate_points(nb_pts_controle)
    tempsbernstein = []
    tempscasteljau = []
    tempscasteljausub = []

    for i in tqdm(range(debut, fin, pas)):
        nb_echantillons = i
        list_t = generate_samples(nb_samples=nb_echantillons)

        t1 = time()
        liste_points = bezier_bernstein(X_pts_controles, Y_pts_controles, list_t)
        liste_points = np.array(liste_points)
        t2 = time()
        tempsbernstein.append(t2 - t1)

        t1 = time()
        liste_points = []
        for tt in list_t:
            # Approximation of the abscissas
            x = de_casteljau(X_pts_controles, tt)
            # Approximation of the ordinates
            y = de_casteljau(Y_pts_controles, tt)
            liste_points.append([x, y])
        t2 = time()
        tempscasteljau.append(t2 - t1)

        t1 = time()
        nb_subdivision = np.round(np.log(nb_echantillons / nb_pts_controle) / np.log(2))
        (X_subdivision, Ysubdivision) = de_casteljau_subdivision(X_pts_controles, Y_pts_controles, nb_subdivision)
        t2 = time()
        tempscasteljausub.append(t2 - t1)

    plt.figure()
    plt.plot(range(debut, fin, pas), tempsbernstein, color='red', label='Bernstein')
    plt.plot(range(debut, fin, pas), tempscasteljau, color='blue', label='Casteljau')
    plt.plot(range(debut, fin, pas), tempscasteljausub, color='green', label='Casteljau Subdivision')
    plt.legend()
    plt.xlabel('number of control points')
    plt.ylabel('computing time')

    # Set axes to logarithmic scale
    plt.yscale('log')

    plt.show()


### Display all steps of the 3D surface in tensor product
def show_surface(X, Y, Z, interpolated_surface):
    fig = plt.figure(figsize=(12, 15))
    ax = fig.add_subplot(131, projection='3d')
    ax.xscale(20)
    ax.set_title('Control points')
    ax.scatter(X, Y, Z, c='red')

    if interpolated_surface[0].shape[0] != 0:
        ax3 = fig.add_subplot(132, projection='3d')
        ax3.set_title('Sampling')
        ax3.scatter(X, Y, Z, c='red')
        ax3.scatter(interpolated_surface[:, :, 0].reshape(-1, 1), interpolated_surface[:, :, 1].reshape(-1, 1),
                    interpolated_surface[:, :, 2].reshape(-1, 1))
        for i in range(interpolated_surface.shape[0]):
            ax3.plot(interpolated_surface[i, :, 0], interpolated_surface[i, :, 1], interpolated_surface[i, :, 2])
            ax3.plot(interpolated_surface[:, i, 0], interpolated_surface[:, i, 1], interpolated_surface[:, i, 2])

        ax5 = fig.add_subplot(133, projection='3d')
        ax5.set_title('Interpolating surface')
        ax5.scatter(X, Y, Z, c='red')
        ax5.plot_surface(interpolated_surface[:, :, 0], interpolated_surface[:, :, 1], interpolated_surface[:, :, 2],
                         cmap='viridis', edgecolor='k')

    plt.show()


def afficher_surface(X, Y, Z, interpolated_surface, nom):
    # Create the 3D plot
    fig = go.Figure(data=[go.Scatter3d(
        x=X.flatten(),
        y=Y.flatten(),
        z=Z.flatten(),
        mode='markers',  # Use 'lines' for a line, 'lines+markers' for both
        marker=dict(size=2, color='rgba(152, 0, 0, .8)', line=dict(width=1, color='rgb(0, 0, 0)')),
        showlegend=False,
        name="control points"
    )])

    min_value = np.min([X.min(), Y.min(), Z.min()])
    max_value = np.max([X.max(), Y.max(), Z.max()])

    # Update layout to standardize axes
    fig.update_layout(
        title=nom,
        autosize=False,
        width=700,  # Adjust width and height for the same proportions
        height=700,
        margin=dict(l=65, r=50, b=65, t=90),
        scene=dict(
            aspectmode='cube',  # Cube aspect ratio for equal axes
            xaxis=dict(range=[min_value, max_value], title='X Axis'),
            yaxis=dict(range=[min_value, max_value], title='Y Axis'),
            zaxis=dict(range=[min_value, max_value], title='Z Axis')
        )
    )

    # Plot the approximated points
    X_approx = interpolated_surface[:, :, 0]
    Y_approx = interpolated_surface[:, :, 1]
    Z_approx = interpolated_surface[:, :, 2]

    fig.add_trace(go.Scatter3d(
        x=X_approx.flatten(),
        y=Y_approx.flatten(),
        z=Z_approx.flatten(),
        mode='markers',  # Use 'lines' for a line, 'lines+markers' for both
        marker=dict(size=2, color='rgba(0, 152, 0, .8)', line=dict(width=1, color='rgb(0, 0, 0)')),
        showlegend=False,
        name="approximated points"

    ))

    fig.add_trace(go.Surface(
        x=X_approx,
        y=Y_approx,
        z=Z_approx,
        colorscale=[[0, 'rgba(255, 255, 25, .8)'], [1, 'rgba(255, 255, 25, .8)']],
        showscale=False

    ))

    # Connect the points horizontally
    for i in range(len(X_approx)):
        fig.add_trace(go.Scatter3d(
            x=X_approx[i],
            y=Y_approx[i],
            z=Z_approx[i],
            mode='lines',
            line=dict(
                color='red',
                width=1,
            ),
            showlegend=False,
            hoverinfo='skip'  # Disable hover info
        ))

    # Connect the points vertically
    for j in range(len(X_approx[0])):
        fig.add_trace(go.Scatter3d(
            x=X_approx[:, j],
            y=Y_approx[:, j],
            z=Z_approx[:, j],
            mode='lines',
            line=dict(
                color='red',
                width=1
            ),
            hoverinfo='skip',  # Disable hover info
            showlegend=False
        ))

    # Update layout
    fig.update_layout(
        title='Tensor product',
        scene=dict(
            xaxis_title='X Axis',
            yaxis_title='Y Axis',
            zaxis_title='Z Axis'
        )
    )

    # Trick to enlarge the legend
    fig.add_trace(go.Scatter3d(
        x=[X_approx[0][0]],
        y=[Y_approx[0][0]],
        z=[Z_approx[0][0]],
        mode='markers',
        marker=dict(size=8, color='rgba(152, 0, 0, .8)', line=dict(width=1, color='rgb(0, 0, 0)')),
        showlegend=True,
        name="Control points (Legend)",
    ))

    # Trick to enlarge the legend
    fig.add_trace(go.Scatter3d(
        x=[X_approx[0][0]],
        y=[Y_approx[0][0]],
        z=[Z_approx[0][0]],
        mode='markers',
        marker=dict(size=8, color='rgba(0, 152, 0, .8)', line=dict(width=1, color='rgb(0, 0, 0)')),
        showlegend=True,
        name="Approximated points (Legend)",
    ))

    # Modify layout display
    fig.update_layout(
        legend=dict(
            traceorder="normal",
            font=dict(
                family="sans-serif",
                size=12,
                color="black"
            ),
            bgcolor="LightSteelBlue",
            bordercolor="Black",
            borderwidth=2
        )
    )

    # Display the plot
    fig.show()


class BernsteinApprox:
    def __init__(self, xlim, ylim, max_points):
        self.points = []
        self.max_points = max_points
        self.fig, self.ax = plt.subplots()
        self.ax.set_xlim(xlim)
        self.ax.set_ylim(ylim)
        self.ax.set_title(f'Click to place up to {max_points} points')
        self.cid = self.fig.canvas.mpl_connect('button_press_event', self.onclick)
        self.ani = None  # Variable to hold the animation

        self.reset_button = widgets.Button(description='Reset')
        self.reset_button.on_click(self.reset)
        # Create a button to calculate the Bézier curve
        self.calc_button = widgets.Button(description="Calculate")
        self.calc_button.on_click(self.calculate_bezier)

        display(self.fig.canvas)  # Use display to show the figure in Jupyter
        display(self.reset_button)  # Show the reset button
        display(self.calc_button)  # Show the reset button

    def reset(self, event):
        self.points = []
        self.ax.cla()
        self.ax.set_xlim(self.ax.get_xlim())
        self.ax.set_ylim(self.ax.get_ylim())
        self.ax.set_title(f'Click to place up to {self.max_points} points')

    def onclick(self, event):
        if event.inaxes is not None and len(self.points) < self.max_points:
            self.points.append((event.xdata, event.ydata))
            self.ax.plot(event.xdata, event.ydata, 'ro')

    def calculate_bezier(self, event):
        self.interpolate_and_animate()

    def interpolate_and_animate(self):
        XX, YY = zip(*self.points)
        self.ax.plot(XX, YY, color="green", linestyle='--')
        temps = np.linspace(0, 1, 1000)

        # Neville interpolation points
        approximated_points_bernstein = bezier_bernstein(XX, YY, temps)

        # Lagrange interpolation points
        # interpolated_points_lagrange = [lagrange(XX, YY, x) for x in temps]

        # Dynamic limits based on interpolation points
        all_x_points = approximated_points_bernstein[:, 0]
        all_y_points = approximated_points_bernstein[:, 1]

        self.ax.set_xlim(min(XX) - 0.2, max(XX) + 0.2)
        self.ax.set_ylim(min(YY) - 0.2, max(YY) + 0.2)

        # Plot Neville interpolation
        line_neville, = self.ax.plot([], [], 'b-', label='Bezier Bernstein')

        self.ax.legend()

        def init():
            line_neville.set_data([], [])
            return line_neville,

        def animate(i):
            x_vals = approximated_points_bernstein[:i, 0]
            y_vals_neville = approximated_points_bernstein[:i, 1]
            line_neville.set_data(x_vals, y_vals_neville)
            return line_neville,

        self.ani = FuncAnimation(self.fig, animate, init_func=init, frames=len(temps), interval=0.1, blit=True,
                                 repeat=False)
        plt.draw()
