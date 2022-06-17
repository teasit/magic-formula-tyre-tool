function stop = fitterOutputFcn(x,optimValues,state,dlg,fitter)
%FITTEROUTPUTFCN Used for the "OutputFcn" of fmincon's optimizing settings.
%   Enables cancellation of the fitting process without losing the
%   progress. When the user presses the "Cancel" button on a progress
%   dialogue, the fitter exits ("stop" flag is set to "true").
%
%   Also updates progress dialog while iterating with most important
%   information.
%
arguments
    x
    optimValues
    state
    dlg matlab.ui.dialog.ProgressDialog
    fitter magicformula.v62.Fitter
end
persistent fval0
if isempty(fval0)
    fval0 = optimValues.fval;
elseif optimValues.iteration == 0
    fval0 = optimValues.fval;
end
if dlg.CancelRequested
    stop = true;
else
    stop = false;
end
switch state
    case 'init'
        message = 'Initializing Solver...';
    case 'iter'
        message = [...
            'Active Fit-Mode: %s' newline() newline() ...
            'Iteration: \t\t\t\t\t%d' newline(),  ...
            'Function Evaluations: \t\t%d' newline(),  ...
            'Objective Function Value: \t%.3E (%+.2f%%)'];
        fitmode = fitter.ActiveFitMode;
        funccount = optimValues.funccount;
        iteration = optimValues.iteration;
        fval = optimValues.fval;
        fvalIncr = (fval-fval0)/fval0*100;
        message = sprintf(message, ...
            fitmode, iteration, funccount, fval, fvalIncr);
    otherwise
        return
end
message = [message newline() newline() 'See console/logfile for details.'];
dlg.Message = message;
end