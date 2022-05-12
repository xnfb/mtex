%% S2Kernels

rng('default')
psi = S2DeLaValleePoussin(10);
%plot(psi)
figure(1)
F1 = S2FunHarmonic(psi);
plot(F1)

F2 = S2FunHandle( @(v) psi.eval(cos(angle(vector3d.Z,v))) );
figure(2)
plot(F2)

v=vector3d.rand
F1.eval(v)
F2.eval(v)

%% SO3 Kernels

rng(4)
psi = SO3DeLaValleePoussinKernel(4);
%plot(psi)
figure(1)
F1 = SO3FunHarmonic(psi);
plot(F1)

F2 = SO3FunHandle( @(rot) psi.eval(cos(angle(rot)/2)) );
figure(2)
plot(F2)

r = rotation.rand
F1.eval(r)
F2.eval(r)


%% convolution SO3Fun with SO3Fun
% Left sided (*L) and Right sided (*R) works

clear 
rng('default')

F1 = SO3FunHarmonic(rand(1e3,1),crystalSymmetry('1'),specimenSymmetry('3'))
F2 = SO3FunHarmonic(rand(1e2,1),crystalSymmetry('4'),specimenSymmetry('1'))
r = rotation.rand

% Left sided convolution
C=conv(F1,F2)
C.eval(r)
mean(SO3FunHandle(@(rot) F1.eval(rot).*F2.eval(inv(rot).*r)))

% calcMDF
F1 = SO3FunHarmonic(rand(1e3,1),crystalSymmetry('3'),specimenSymmetry('1'))
F1.fhat = conj(F1.fhat);
C = conv(inv(conj(F1)),F2)
C.eval(r)
cF1 = conj(F1);
mean(SO3FunHandle(@(rot) cF1.eval(rot).*F2.eval(rot.*r)))

% right sided convolution
F1 = SO3FunHarmonic(rand(1e3,1),crystalSymmetry('4'),specimenSymmetry('622'))
F2 = SO3FunHarmonic(rand(1e2,1),crystalSymmetry('622'),specimenSymmetry('3'))
C = conv(F1,F2,'Right');
C.eval(r)
mean(SO3FunHandle(@(rot) F1.eval(rot).*F2.eval(r.*inv(rot))))


%% convolution SO3Fun with S2Fun
% works
rng('default')
p = vector3d.rand;

F1 = SO3FunHarmonic(rand(1e5,1)+rand(1e5,1)*1i,crystalSymmetry('622'),specimenSymmetry('3'));
%F1.isReal=1
F2 = S2FunHarmonicSym(rand(40^2,1)+1i*rand(40^2,1),specimenSymmetry('622'));

C = conv(F1,F2);
C.eval(p)

A = SO3FunHandle(@(rot) F1.eval(rot).*F2.eval(rot.*p));
mean(A)

%% convolution SO3Fun with SO3Kernel & SO3Kernel with SO3Fun
% SO3F *L psi  ==  SO3F *R psi  ==  psi *R SO3F  ==  psi *L SO3F
% works
rng(1)
r = rotation.rand;

F1 = SO3FunHarmonic(rand(1e5,1)+rand(1e5,1)*1i);%,crystalSymmetry('622'),specimenSymmetry('3'));
%F1.isReal=1
F2 = SO3DeLaValleePoussinKernel;

CL = conv(F1,F2); CL.eval(r)
CR = conv(F1,F2,'Right'); CR.eval(r)
CLi = conv(F2,F1); CLi.eval(r)
CRi = conv(F2,F1,'Right'); CRi.eval(r)

F2 = SO3FunHarmonic(F2);
C3 = conv(F1,F2); C3.eval(r)
C4 = conv(F1,F2,'Right'); C4.eval(r)
C5 = conv(F2,F1); C5.eval(r)
C6 = conv(F2,F1,'Right'); C6.eval(r)


%mean(SO3FunHandle(@(rot) F1.eval(rot).*F2.eval(inv(rot).*r)))
%mean(SO3FunHandle(@(rot) F2.eval(rot).*F1.eval(inv(rot).*r)))

%% convolution SO3Fun with S2Kernel
% works
rng(2)
p = vector3d.rand;

F1 = SO3FunHarmonic(rand(1e5,1)+rand(1e5,1)*1i);%,crystalSymmetry('622'),specimenSymmetry('3'));
psi = S2DeLaValleePoussin(10);

C1 = conv(F1,psi);
C1.eval(p)
figure(1)
plot(C1)

F2 = S2FunHarmonic(psi);
C2 = conv(F1,S2FunHarmonic(F2));
C2.eval(p)
figure(2)
plot(C2)

%% convolution SO3Kernel with SO3Kernel
% works
psi1 = SO3DeLaValleePoussinKernel(4);
psi2 = SO3GaussWeierstrassKernel;

C1 = SO3FunHarmonic(conv(psi1,psi2));
C2 = conv(SO3FunHarmonic(psi1),SO3FunHarmonic(psi2));


figure(1)
plot(C1)
figure(2)
plot(C2)

%% convolution SO3Kernel with S2Kernel
% works
psi1 = SO3DeLaValleePoussinKernel(4);
psi2 = S2DeLaValleePoussin(10);

C1 = S2FunHarmonic(conv(psi1,psi2));
C2 = conv(SO3FunHarmonic(psi1),S2FunHarmonic(psi2));

figure(1)
plot(C1)
figure(2)
plot(C2)

%% convolution SO3Kernel with S2Fun
% works
psi = SO3DeLaValleePoussinKernel(4);
sF = S2Fun.smiley;

C1 = conv(psi,sF);
C2 = conv(SO3FunHarmonic(psi),sF);

figure(1)
plot(C1)
figure(2)
plot(C2)

%% convolution SO3FunRBF with SO3Kernel
% works
F1 = SO3FunRBF.example;
psi = SO3DeLaValleePoussinKernel;

C1 = SO3FunHarmonic(conv(F1,psi))
C2 = conv(SO3FunHarmonic(F1),psi)

figure(1)
plot(C1)
figure(2)
plot(C2)
%% convolution SO3FunRBF with SO3FunRBF
rng(0)
F1 = SO3FunRBF.example;
F1.CS = crystalSymmetry('2');
ori = orientation.rand(10,crystalSymmetry('1'),specimenSymmetry('2'));
F2 = SO3FunRBF(ori,SO3DeLaValleePoussinKernel('halfwidth',5*degree));

C3 = conv(F1,F2)
C4 = conv(SO3FunHarmonic(F1),F2)

r=rotation.rand(3);
C3.eval(r)
C4.eval(r)

%% convolution S2Fun with S2Fun
rng(6)
r=rotation.rand(1);

F1 = S2FunHarmonic([1,0.0001,0,0]');
F2 = S2FunHarmonic(1);%,specimenSymmetry('622'));

C = conv(F1,F2)
C.eval(r)

C2 = SO3FunHandle(@(rot) mean(S2FunHandle(@(v) F1.eval(v).*F2.eval(rot.*(v)))))
C2.eval(r)




