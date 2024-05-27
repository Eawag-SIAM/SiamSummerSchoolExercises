import numpy as np
from scipy.integrate import odeint

def model_monod(par, C):
    """
    Model:
    ------
    Growth rate as a function of substrate concentration:
    r = r_max * C / (K + C)
    
    Arguments:
    ----------
    - par: array containing the following parameters:
        - par[0]: 'r_max' (maximum growth rate)
        - par[1]: 'K' (half-saturation concentration)
    - C: vector containing substrate concentrations
    
    Returns:
    -------
    r: A vector of growth rates
    """
    # Extract parameter values from the array
    r_max = par[0]
    K = par[1]
    
    # Calculate growth rate using the Monod model
    r = r_max * C / (K + C)
    
    # Return growth rates
    return r


def model_growth(par, times):
    """
    Model:
    ------
    Growth of microorganisms on a substrate in a batch reactor:
    dC_M / dt = mu * C_S / (K + C_S) * C_M - b * C_M
    dC_S / dt = -1 / Y * mu * C_S / (K + C_S) * C_M
    
    Arguments:
    ----------
    - par: array containing the following parameters:
        [mu, K, b, Y, C_M_ini, C_S_ini]
    - times: array of time points to evaluate the ODE
    
    Value:
    ------
    A dictionary containing `C_M` and `C_S` for all points in `time`.
    """
    
    # Check if the correct number of parameters are provided
    if len(par) < 6:
        raise ValueError("Error in model_growth: wrong number of parameters provided")

    # Define the right-hand side of the ODE
    def rhs_growth(C, t, par):
        """
        Define right-hand side of the ODE.
        """
        
        # Extract state variables and parameters from the inputs
        C_M, C_S = C
        mu = par[0]  # mu: maximum growth rate of microorganisms
        K = par[1]  # K: half-concentration of growth rate with respect to substrate
        b = par[2]  # b: rate of death and respiration processes of microorganisms
        Y = par[3]  # Y: yield of growth process
        
        # Calculate the rates of change
        r_M = mu * C_S / (K + C_S) * C_M - b * C_M
        r_S = -1 / Y * mu * C_S / (K + C_S) * C_M
        
        # Return the rates as a list
        return [r_M, r_S]
    
    # Initial concentrations from the parameter array
    C_M_ini = par[4]  # Initial concentration of microorganisms
    C_S_ini = par[5]  # Initial concentration of substrate
    
    # Initial state
    C_ini = [C_M_ini, C_S_ini]
    
    # Solve the ODE system using odeint
    res_ode = odeint(rhs_growth, C_ini, times, args=(par,))
    
    # Return the results as a dictionary
    return {"time": times, "C_M": res_ode[:, 0], "C_S": res_ode[:, 1]}


