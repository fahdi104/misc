%asc2sofi.m
%conv to SOFI binary from SU single coloumn ascii, for 3D case

%clear all;
clc
tic
%p=load('data.ascii');
toc
tic

%
nx=801;
nz=801;
ny=187; %y is vertical time as per sofi
delta=25;
deltaT=0.25;
modname='ovt';
%var end here

%reshape to xyz
q=reshape(p,nx,ny,nz); 

%limit model
nx=200;
nz=200;
ny=180;
q=q(:,1:ny,:);

%qc load
line=200;
r=q(line,:,1:nx); %tolol kebalik
s=reshape(r,nx,ny);
imagesc(s')

%permute to sofi, and output
vp_mod=permute(q,[2 1 3]).*1000;

fid_mod=fopen(strcat(modname,'.vp'),'w');
fwrite(fid_mod,vp_mod,'float');
fclose(fid_mod);

%get vs, and output

vs_mod=vp_mod./2;
fid_mod=fopen(strcat(modname,'.vs'),'w');
fwrite(fid_mod,vs_mod,'float');
fclose(fid_mod);

%get rho, and output
rho_mod=gardner(vp_mod);
fid_mod=fopen(strcat(modname,'.rho'),'w');
fwrite(fid_mod,rho_mod,'float');
fclose(fid_mod);

toc

