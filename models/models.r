## -------------------------------------------------------
##
## Example models used for the
## Eawag Summer School in Environmental Systems Analysis
##
## Original code by Peter Reichert <peter.reichert@eawag.ch> 
## -------------------------------------------------------

library(deSolve)

model.monod <- function(par, C){
    ## model:
    ## ------
    ##
    ##   growth rate as a function of substrate concentration:
    ##
    ##   r = r_max*C / (K + C)
    ##
    ## arguments:
    ## ----------
    ##
    ##  - par: vector containing the following parameters:
    ##           r_max    maximum growth rate
    ##           K        half-saturation concentration
    ##         The vector can be named.
    ##  - C:   vector containing substrate concentrations
    ##
    ## value:
    ## ------
    ##
    ## A vector of growth rates
    ## --------

    
    ## check input:
    ## ------------

    if (length(par) < 2) {
        stop("error in model.monod: insufficent number of parameters provided")
    }


    ## assign parameter values:
    ## ------------------------

    r_max <- par["r_max"]; if (is.na(r_max)) r_max <- par[1]
    K <- par["K"]; if (is.na(K)) K <- par[2]

    ## calculate results:
    ## ------------------

    r <- r_max*C/(K+C)

    ## return results:
    ## ---------------

    res <- as.numeric(r)
    names(res) <- paste("r_",C,sep="")
    return(res)
}


###############################################################################


model.growth <- function(par, times)
{
    ## model:
    ## ------
    ##
    ##   growth of microorganisms on a substrate in a batch reactor:
    ##
    ##   dC_M         C_S
    ##   ----  =  mu ----- C_M  -  b C_M
    ##    dt         K+C_S
    ##
    ##   dC_S      mu   C_S
    ##   ----  = - --  ----- C_M
    ##    dt       Y   K+C_S
    ##
    ## state variables:
    ##   C_M      concentration of microorganisms in the reactor
    ##   C_S      concentration of substrate in the reactor
    ##
    ## argments:
    ## -----------
    ##
    ##  - par:  vector containing the following parameters:
    ##             mu       maximum growth rate of microorganisms
    ##             K        half-concentration of growth rate with respect to substrate
    ##             b        rate of death and respiration processes of microorganisms
    ##             Y        yield of growth process
    ##             C_M_ini  initial concentration of microorganisms
    ##             C_S_ini  initial concentration of substrate
    ##           The vector can be named.
    ##  - times: vector of time points to evalute the ODE
    ##
    ## value:
    ## ------
    ##
    ## A data frame containing `C_M` and `C_S` for all points in `time`
    ##
    ## example:
    ## --------
    ##
    ## p <- c(mu=0.2,
    ##        K=3, 
    ##        b=0.1, 
    ##        Y=0.1, 
    ##        C_M_ini=1,
    ##        C_S_ini=10
    ## )
    ## times <- seq(0, 10, length=21)
    ## model.growth(p, times)
    ##
    ## --------


    ## check input:
    ## ------------

    if ( length(par) != 6 )
    {
        stop("error in model.growth: wrong number of parameters provided")
    }

    ## define right hand side of ODE
    ## ------------

    rhs.growth <- function(t, C, par){  # changed LW (deSolve requires arguments in this order)
        
        ## check input:
        ## ------------

        if ( length(par) < 6 )
        {
            stop("error in rhs.growth: insufficient number of parameters provided")
        }

        ## assign state variable and parameter values:
        ## -------------------------------------------

        C_M <- C[1]
        C_S <- C[2]
        mu <- par["mu"]; if (is.na(mu)) mu <- par[1]
        K <- par["K"];  if (is.na(K))  K <- par[2]
        b <- par["b"];  if (is.na(b))  b <- par[3]
        Y <- par["Y"];  if (is.na(Y))  Y <- par[4]

        ## calculate results:
        ## ------------------

        r_M <- mu*C_S/(K+C_S)*C_M - b*C_M
        r_S <- - 1/Y * mu*C_S/(K+C_S)*C_M

        ## return result:
        ## --------------

        res <- numeric(0)
        res[1] <- r_M
        res[2] <- r_S
        return(list(res))  # deSolve "ode" requires as a list
    }

    ## solve ODE
    ## ------------------

    C_M_ini <- par["C_M_ini"]; if (is.na(C_M_ini)) C_M_ini <- par[5]  
    C_S_ini <- par["C_S_ini"]; if (is.na(C_S_ini)) C_S_ini <- par[6] 

    C_ini <- c(C_M=C_M_ini, C_S=C_S_ini)


    res_ode <- deSolve::ode(y=C_ini, times=times, func=rhs.growth,
                            parms=par, method="rk4")

    ## return results:
    ## ---------------

    res_ode_df <- as.data.frame(res_ode)  
    colnames(res_ode_df) <- c("time", "C_M", "C_S")
    return(res_ode_df)
}


###############################################################################


