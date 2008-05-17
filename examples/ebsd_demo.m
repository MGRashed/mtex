%% MTEX - Analysis of EBSD Data
%
% Analysis of single orientation measurement.
%
% 
% 

%% Specify Crystal and Specimen Symmetry

cs = symmetry('cubic');
ss = symmetry('triclinic');

%% Load EBSD Data

ebsd = loadEBSD([mtexDataPath,'/aachen_ebsd/85_829grad_07_09_06.txt'],cs, ...
                ss,'header',1,'layout',[5,6,7,2],'phase',1)

%% Plot Pole Figures as Scatter Plots

h = [Miller(1,0,0),Miller(1,1,0),Miller(1,1,1)];
close; figure('position',[100,100,600,300])
plotpdf(ebsd,h,'points',500,'reduced')

%% Kernel Density Estimation
%
% The crucial point in kernel density estimation in the choice of the
% halfwidth of the kernel function used for estimation. If the halfwidth of
% is chosen to small the single orientations are visible rather
% then the ODF (compare plot of ODF1). If the halfwidth is chosen to wide
% the estimated ODF becomes very smooth (ODF2).
%
odf1 = calcODF(ebsd)
odf2 = calcODF(ebsd,'halfwidth',10*degree)

%% plot pole figures

close all;figure('position',[160   389   632   216])
plotpdf(odf1,h,'reduced')
figure('position',[160   389   632   216])
plotpdf(odf2,h,'reduced')

%% plot ODF

close;figure('position',[46   300   702   300]);
plotodf(odf2,'sections',9,'resolution',2*degree,...
  'FontSize',10,'silent')
   
%% Estimation of Fourier Coefficients
%
% Once, a ODF has been estimated from EBSD data it is straight forward to
% calculate Fourier coefficients. E.g. by
F2 = Fourier(odf2,'order',4);

%%
% However this is a biased estimator of the Fourier coefficents which
% underestimates the true Fourier coefficients by a factor that
% correspondes to the decay rate of the Fourier coeffients of the kernel
% used for ODF estimation. One obtains a *unbiased* estimator of the
% Fourier coefficients if they are calculated from the ODF estimated with
% the help fo the Direchlet kernel. I.e.

dirichlet = kernel('dirichlet',32);
odf3 = calcODF(ebsd,'kernel',dirichlet);
F3 = Fourier(odf3,'order',4);

%%
% Let us compare the Fourier coefficients obtained by both methods.
%

plotFourier(odf2,'bandwidth',32)
hold all
plotFourier(odf3,'bandwidth',32)
hold off

%% A Sythetic Example
%
% Simulate EBSD data from a given standard ODF

fibre_odf = 0.5*uniformODF(cs,ss) + 0.5*fibreODF(Miller(1,0,0),zvector,cs,ss);
plotodf(fibre_odf,'sections',9,'silent')
ebsd = simulateEBSD(fibre_odf,1000)

%% 
% Estimate an ODF from the simulated EBSD data

odf = calcODF(ebsd)

%%
% plot the estimated ODF

plotodf(odf,'sections',9,'silent')

%%
% calculate estimation error
calcerror(odf,fibre_odf,'resolution',5*degree)

%% Exploration of the relationship between estimation error and number of single orientations
%
% simulate 10, 100, ..., 1000000 single orientations of the Santafee sample ODF, 
% estimate an ODF from these data and calcuate the estimation error

odf = {};
for i = 1:6

  ebsd = simulateEBSD(fibre_odf,10^i);
  odf = calcODF(ebsd);
  e(i) = calcerror(odf,fibre_odf,'resolution',2.5*degree);
  
end

%% 
% plot the error in dependency of the number of single orientations
close all;
semilogx(10.^(1:6),e)

% %% 
% % plot Fourier coefficients in dependency of the 
% colororder = ['b','g','r','c','m','k','y'];
% l = {};
% for i = 2:6
%   plotFourier(odf{i},'color',colororder(i));
%   l = {l{:},['10^' int2str(i) ' points - de la Vallee Poussin']};
%   hold on
%   plotFourier(fodf{i},'color',colororder(i),'LineStyle',':');
%   l = {l{:},['10^' int2str(i) ' points - Dirichlet']};
% end
% plotFourier(santafee,'color','k','Linewidth',2,'bandwidth',32);
% ylim([0,0.4])
% legend(l)
% hold off
% 
% %% 
% % plot Fourier coefficients in dependency of the 
% colororder = ['b','g','r','c','m','k','y'];
% l = {};
% for i = 2:6
%   plotFourier(odf{i},'color',colororder(i),'LineStyle','none','Marker','o');
%   l = {l{:},['10^' int2str(i) ' points - de la Vallee Poussin']};
%   hold on
%   plotFourier(fodf{i},'color',colororder(i),'LineStyle','none','Marker','x');
%   l = {l{:},['10^' int2str(i) ' points - Dirichlet']};
% end
% plotFourier(santafee,'color','k','Marker','d','bandwidth',32,'LineStyle','none');
% ylim([0,0.4])
% legend(l)
% hold off
