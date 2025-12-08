# GloFM: a Glorys Flow-Matching emulator for spatio-temporal ocean data assimilation
## Abstract
Providing regular and physically consistent predictions of the ocean state is critical for numerous scientific, operational, and societal needs. Observations of the ocean surface are gathered through various remote sensing and in situ instruments, and are typically assimilated into numerical models to reconstruct the ocean state. However, this often involves millions of data points, making it computationally intensive, which suggests deep learning may be a cheaper alternative. Deterministic data-driven approaches typically learn about ocean dynamics from numerical simulations or sparse observational data. However, such methods often lack physical realism in uncertain settings. Due to mode averaging, they produce non-physical or overly simplified states. Generative models offer a promising approach to generating physically realistic ocean states. 

We present GloFM: a Glorys Flow-Matching emulator for spatio-temporal ocean data assimilation. Our generative model produces coherent estimates of ocean surface fields. GloFM uses flow matching to assimilate observational data for nowcasting of surface currents, sea surface height (SSH), and sea surface temperature (SST). Compared to deterministic regression-based approaches, GloFM demonstrates improved realism metrics, capturing finer-scale variability and more physically plausible ocean states.

## Using GloFM for forecast

Given a FM model trained for unconditional sampling on GLORYS, we want to estimate $p\left( x_1^{1:T}\mid y^{-\tau:0} \right)$. To do so, we compare 2 algorithms:

1) Full sequence multi-flow matching, where we directly sample $p(x_1^{-\tau:T_F}\mid y^{-\tau: 0})$, using the ODE defined in Equation \eqref{eq:post_ode}, combining the prediction of several inferences using sliding windows, and assimilating the observations of the start of the timeseries. This approach is described for DDPM models in \citet{rozet_score-based_2023}.
2) Auto regressive Markovian generation, where we start by generating $p\left(x_1^{-\tau:0}\mid y^{-\tau: 0}\right)$, then sequentially generate $p\left(x_1^{n}|x_1^{n-7:n-1}\right)$, starting with $n=1$, stopping at $n=T_F$, incrementing $n$ by $1$. See Appendix~\ref{apx:ar_fcast} for details.

To sample the distribution $p\left( x_1^{-\tau:T_F}\mid y^{-\tau:0} \right)$, with $x_1^i$ the sampled states, $y^{-\tau:0}$ the observation and $v_\theta(x_s,s)$,  we first sample $p\left(x_1^{-\tau:0}\mid y^{-\tau:0} \right)$, using MMPS~\ref{eq:post_ode}. With $\tau=6$.

Then in order to sample $p\left(x_1^{1}\mid x_1^{-6:0}\right)$, we use \cite{rozet_score-based_2023} simpler posterior sampling algorithm as MMPS algorithm complexity scales with $k^2$. In this algorithm, $A\mathbb{V}[x \mid  x_s] A^\top$ is approximated with a diagonal matrix $(1-s)\Gamma$, with $\Gamma$ set to $2I$. Using this simpler algorithm reduces the complexity of the posterior sampling but makes it less stable when assimilated observations are far away from the prior distribution.
We then sample all remaining timesteps using the same methodology, sequentially sampling $\left(p\left(x^n_1\mid x_1^{n-7:n-1}\right)\right)_{n\in \left\{ 2\ldots T_F\right\}}$.

These algoritmhs are computationnally expansive, the few forecasting results we produced using these methods are presented in the next figures:
<figure>
 <img
 src=figures/forecast/maps/fs.gif
 alt="fs">
 <figcaption>Forecasting using full sequence sampling</figcaption>
</figure>

<figure>
 <img
 src=figures/forecast/maps/ar.gif
 alt="ar">
 <figcaption>Forecasting using autoregression sampling</figcaption>
</figure>

## Forecast evaluation

| RMSE                       | CRPS |
|----------------------------|------|
|![RMSE](figures/forecast/evaluation/RMSE_combined.png) | ![CRPS](figures/forecast/evaluation/CRPS_combined.png) |


<figure>
 <img
 src=figures/forecast/evaluation/Rank_Histogram_combined.png
 alt="RH">
 <figcaption>Evaluation of the forecast fields on remote sensing and in situ observations. Evaluations of the auto-regressively generated ensembles are drawn in blue, and evaluations of the full-sequence sampling approach are drawn in orange</figcaption>
</figure>



We report the results of the ensemble forecasting, comparing the two approaches in Figure~\ref{fig:forecast_metrics}. SST prediction metrics are better for far horizons (after 8 days of predictions for the CRPS) for the full sequence sampling approach. The auto-regressive method provides substantially better metrics than the full sequence sampling approach. 

