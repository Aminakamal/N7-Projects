import math
import numpy as np
from typing import List, Tuple


#####################################################
############## Lagrange functionnal setting #########
#####################################################


def lagrange(YY: List[float], TT: List[float], t: float) -> float:
    """Calculate Lagrange interpolation for a given point.

    Args:
        YY (List[float]): The y-coordinates of the data points.
        TT (List[float]): The x-coordinates of the data points.
        t (float): The point at which to evaluate the interpolated polynomial.

    Returns:
        float: The interpolated value at point t.
    """
    n = len(TT)
    value = 0.0

    for i in range(n):
        li = 1.0
        for j in range(n):
            if i != j:
                li *= (t - TT[j]) / (TT[i] - TT[j])
        value += YY[i] * li

    return float(value)


#####################################################
############## Neville's algorithm ##################
#####################################################


def neville(YY: np.ndarray, TT: np.ndarray, t: float) -> float:
    """
    Perform polynomial interpolation using Neville's algorithm.

    Args:
        YY (np.ndarray): The y-coordinates of the data points.
        TT (np.ndarray): The times where datapoints are interpolated.
        t (float): The value at which the interpolation is calculated.

    Returns:
        float: The interpolated value at x.
    """
    q = np.array(YY, dtype=float).copy()
    tt = np.array(TT, dtype=float)
    n = len(q)

    for level in range(1, n):
        for i in range(n - level):
            numerator = (t - tt[i + level]) * q[i] + (tt[i] - t) * q[i + 1]
            denominator = tt[i] - tt[i + level]
            q[i] = numerator / denominator

    return float(q[0])


#####################################################
################ Time sampling ######################
#####################################################


def tchebycheff_parametrisation(nb_point: int) -> List[float]:
    """
    Compute the Tchebycheff abscissas for a given number of points (from -1 to 1).

    Args:
        nb_point (int): The number of points for which the Tchebycheff abscissas must be computed.

    Returns:
        List[float]: A list containing the Tchebycheff abscissas.
    """
    if nb_point <= 0:
        return []

    nodes = [0.5 * (1 - math.cos((2 * k + 1) * math.pi / (2 * nb_point))) for k in range(nb_point)]
    nodes.sort()
    return nodes



def regular_parametrisation(nb_point: int) -> List[float]:
    """
    Create regular subdivision with the first point at 0 and the last at 1.

    Args:
        nb_point (int): The number of points for which regular abscissas are calculated.

    Returns:
        List[float]: A list containing the regular abscissas.
    """
    if nb_point <= 0:
        return []
    if nb_point == 1:
        return [0.0]
    return np.linspace(0.0, 1.0, nb_point).tolist()


def distance_parametrisation(XX: List[float], YY: List[float]) -> List[float]:
    """
    Create subdivision where spacing between points is proportional to their distance in R2,
    with the first point at 0 and the last at 1.

    Args:
        XX (List[float]): The X coordinates of the points.
        YY (List[float]): The Y coordinates of the points.

    Returns:
        List[float]: A list containing the abscissas proportional to the distances.
    """
    n = len(XX)
    if n == 0:
        return []
    if n == 1:
        return [0.0]

    cum_dist = [0.0]
    for i in range(1, n):
        d = math.sqrt((XX[i] - XX[i - 1]) ** 2 + (YY[i] - YY[i - 1]) ** 2)
        cum_dist.append(cum_dist[-1] + d)

    total = cum_dist[-1]
    if total == 0:
        return regular_parametrisation(n)

    return [d / total for d in cum_dist]



def parametrisation_racinedistance(XX: List[float], YY: List[float]) -> List[float]:
    """
    Create subdivision where spacing between points is proportional to the square root of their distance in R2,
    with the first point at 0 and the last at 1.

    Args:
        XX (List[float]): The X coordinates of the points.
        YY (List[float]): The Y coordinates of the points.

    Returns:
        List[float]: A list containing the abscissas proportional to the square roots of the distances.
    """
    n = len(XX)
    if n == 0:
        return []
    if n == 1:
        return [0.0]

    cum_dist = [0.0]
    for i in range(1, n):
        d = math.sqrt((XX[i] - XX[i - 1]) ** 2 + (YY[i] - YY[i - 1]) ** 2)
        cum_dist.append(cum_dist[-1] + math.sqrt(d))

    total = cum_dist[-1]
    if total == 0:
        return regular_parametrisation(n)

    return [d / total for d in cum_dist]


#####################################################
############ Neville's Algorithm @@@@ ###############
#####################################################


def neville_param(XX, YY, TT, list_tt) -> Tuple[List[float], List[float]]:
    """
    Interpolate points using Neville's algorithm for given x and y coordinates.

    Args:
        XX (list[float]): The x-coordinates of the data points.
        YY (list[float]): The y-coordinates of the data points.
        TT (list[float]): The time points corresponding to the data points.
        list_tt (list[float]): The time points at which to evaluate the interpolation.

    Returns:
        tuple: Two lists containing the interpolated x and y coordinates.
    """
    interpolated_x = [neville(np.array(XX), np.array(TT), tt) for tt in list_tt]
    interpolated_y = [neville(np.array(YY), np.array(TT), tt) for tt in list_tt]
    return interpolated_x, interpolated_y



def surface_interpolation_neville(X, Y, Z, TT_x, TT_y, list_tt, nb_points_x) -> np.ndarray:
    """
    Interpolates a surface at given time points using Neville's interpolation method.

    Args:
        X (np.ndarray): X coordinates of 3D points (shape: (nb_points_x, len(TT_y))).
        Y (np.ndarray): Y coordinates of 3D points (shape: (nb_points_x, len(TT_y))).
        Z (np.ndarray): Z coordinates of 3D points (shape: (nb_points_x, len(TT_y))).
        TT_x (List[float]): Times corresponding to the points in X.
        TT_y (List[float]): Times corresponding to the points in Y.
        list_tt (List[float]): Times at which to evaluate the interpolated surface.
        nb_points_x (int): Number of points in the grid for interpolation.

    Returns:
        np.ndarray: Interpolated surface (shape: (len(list_tt), len(list_tt), 3)).
    """
    n = len(list_tt)
    interpolated_surface_1 = np.zeros((nb_points_x, n, 3))  # Intermediate surface
    interpolated_surface = np.zeros((n, n, 3))  # Final interpolated surface

    for i in range(nb_points_x):
        for j, tt_y in enumerate(list_tt):
            interpolated_surface_1[i, j, 0] = neville(X[i, :], TT_y, tt_y)
            interpolated_surface_1[i, j, 1] = neville(Y[i, :], TT_y, tt_y)
            interpolated_surface_1[i, j, 2] = neville(Z[i, :], TT_y, tt_y)

    for j in range(n):
        for i, tt_x in enumerate(list_tt):
            interpolated_surface[i, j, 0] = neville(interpolated_surface_1[:, j, 0], TT_x, tt_x)
            interpolated_surface[i, j, 1] = neville(interpolated_surface_1[:, j, 1], TT_x, tt_x)
            interpolated_surface[i, j, 2] = neville(interpolated_surface_1[:, j, 2], TT_x, tt_x)

    return interpolated_surface
