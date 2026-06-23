%% Import data from text file
% Script for importing data from the following text file:
%
%    filename: wavefolder.txt
%


%% Set up the Import Options and import the data
opts = delimitedTextImportOptions("NumVariables", 2);

% Specify range and delimiter
opts.DataLines = [2, Inf];
opts.Delimiter = "\t";

% Specify column names and types
opts.VariableNames = ["time", "Vvout"];
opts.VariableTypes = ["double", "double"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Import the data
tbl = readtable("sweptCosine.txt", opts);

%% Convert to output type
time = tbl.time;
Vvout = tbl.Vvout;

%% Clear temporary variables
clear opts tbl