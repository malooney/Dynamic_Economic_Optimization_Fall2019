% DEMDP14 Livestock Feeding Model
clc
clear
  fprintf('\nDEMDP14 LIVESTOCK FEEDING MODEL\n')
  close all  

% ENTER MODEL PARAMETERS
  alpha =  0.9;                                         % growth function parameter
  beta  =  0.5;                                         % growth function parameter
  kappa =  0.4;                                         % unit cost of feed
  price =  1.0;                                         % unit price of stock
  T     =  6;                                           % time horizon
  delta =  0.9;                                         % discount factor
  
% PACK MODEL STRUCTURE
  clear model
  model.func = 'mfdp14';                                % model functions
  model.horizon = T;                                    % time horizon
  model.discount = delta;                               % discount factor
  model.params = {alpha beta kappa};                    % other parameters
  
% DEFINE APPROXIMATION SPACE
  n    = 50;                                            % degree of approximation
  smin = 0.4;                                           % minimum state   
  smax = 2.0;                                           % maximum state
  fspace = fundefn('spli',n,smin,smax);                 % function space
  snodes = funnode(fspace);                             % state collocaton nodes
  
% CHECK MODEL DERIVATIVES
  dpcheck(model,(smax+smin)/2,1);

% INITIALIZE POLICY, VALUE, PRICE FUNCTIONS
  xinit = ones(n,1);                                    % guess for terminal policy function
  vterm = price*snodes;                                 % post-terminal value function
  
% SOLVE BELLMAN OR EULER EQUATION
  [c,s,v,x] = dpsolve(model,fspace,snodes,vterm,xinit);
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % PLOT OPTIMAL POLICY
  figure(1);
  plot(s,x(:,1:T)); % added x(:,1:T) to eliminate dim error
  %plot(s,x)
  title('Optimal Feeding Policy');
  xlabel('Stock Weight');
  ylabel('Feed');
  
% PLOT OPTIMAL POLICY Added plots
  x_reshape = reshape(x, [50,T]); % added to eliminate dim error
  hFig = figure(2);
  set(hFig, 'Position', [100 100 1400 800])
  figure(2);
  for i = 1:T % added to plot all time periods
  subplot(2,3,i);
  plot(s, x(:,i));
  title('Optimal Feeding Policy');
  xlabel('Stock Weight');
  ylabel('Feed');
  legend(sprintf('time horizon=%d',i), 'location', 'NorthWest')
  end
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% PLOT VALUE FUNCTION
  figure(3);
  plot(s,v)
  title('Value Function');
  xlabel('Stock Weight');
  ylabel('Value');

% PLOT SHADOW PRICE FUNCTION
  figure(4);
  p = funeval(c,fspace,s,1); 
  plot(s,p);
  title('Shadow Price Function');
  xlabel('Stock Weight');
  ylabel('Price');

% COMPUTE STATE AND POLICY PATH
  sinit = smin;
  [spath,xpath] = dpsimul(model,sinit,T,s,x);
  
% PLOT STATE PATH
  figure(5);
  plot(1:T+1,spath);
  title('State Path');
  xlabel('Month');
  ylabel('Stock Weight');
  xlim([1 7])
  
% PLOT POLICY PATH
  figure(6);
  plot(1:T,xpath);
  title('Policy Path');
  xlabel('Month');
  ylabel('Feed');

% SAVE PLOTS AS EPS FILES
  prtfigs(mfilename,'Solution to the Livestock Feeding Problem',[4 5])