%This Octave program reads a sensing matrix, A, and a set of samples, the columns of bs, and solves b = Ax, returning the matrix xs

path(path, strcat(pwd, '/software/YALL1/'))

%measurement matrix;
A = load('tmp/A.mat');
[n,k] = size(A);

%concatenated columns of b
bs = load('tmp/bs.mat');
[m,s] = size(bs);

%See the YALL1 user guide for info on these parameters
opts.tol = 1e-3;   %stopping tolerance
opts.rho = 0;      %no rho; we want the L1/L2con problem
opts.delta = 1e-3;    %residual should be less than 0.001
opts.nonneg = 0;   %solution is nonnegative, kthx
opts.nonorth = 0;  %not going to bother to orthonormalize A, sorry.
opts.stepfreq = 1; %how often should nonortho matricies be re-doodled (higher is faster, at risk of nonconvergence)
opts.print = 0;    %how verbose?


if opts.nonorth == 0;
  [Q, R] = qr(A',0);
  A = Q'; bs = R'\bs;
end

%preallocate memory
res = zeros(k, s);

%solve the L1/L2con minimization problem for each column in bs, storing the reconstructed solution in xs
for j = 1:s;
  b = bs(:,j);
  [x,Out] = yall1(A, b, opts);
  res(:,j) = x;
end

save 'tmp/xs.mat' -ascii res
