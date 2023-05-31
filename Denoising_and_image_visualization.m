clear all
close all
clc
num_images = 10;    %% Total number of images in the z-stack
for z = 1:num_images %% Loop to read all images in the stack of nucleus and mitochondria
    Nuc_image_name = sprintf('C001Z0%02d.tif',z);
    Mito_image_name = sprintf('C002Z0%02d.tif',z);
    Nuc_image = sum(imread(Nuc_image_name),3);
    Mito_image = sum(imread(Mito_image_name),3);
    threshold_Nuc = 0.4*max(max(Nuc_image));  % 40% threshold for noise removal 
    Nuc_image(Nuc_image < threshold_Nuc) = 0; % all pixles below threhold value are assigned as 0
    threshold_Mito = 0.4*max(max(Mito_image));  % 40% threshold for noise removal 
    Mito_image(Mito_image < threshold_Mito) = 0; % all pixles below threhold value are assigned as 0
    
    Nuc_image_3D(:,:,z) = Nuc_image; % store the nuclues images in a 3D matrix
    Mito_image_3D(:,:,z) = Mito_image; % store the mitochondria images in a 3D matrix
end
Nucleus_MIP = max(Nuc_image_3D, [], 3); % Maximum projection of nucleus
Mito_MIP = max(Mito_image_3D, [], 3); % Maximum projection of mitochondria

figure()
subplot(131)
imshow(Nucleus_MIP); % show maximum projection of nucleus
set(gca,'CLim',[0 255],'Colormap',[zeros(255,1),zeros(255,1),linspace(0,1,255)']); % Blue pseudocolor

subplot(132)
imshow(Mito_MIP); % show maximum projection of mitochondria
set(gca,'CLim',[0 255],...
    'Colormap',[zeros(255,1),linspace(0,1,255)',zeros(255,1)]); % Green pseudocolor

subplot(133)
C = imfuse(Nucleus_MIP,Mito_MIP,'ColorChannels',[0 2 1]); % create a combined image
imshow(C) % show the combined image
print('Sample image', '-dtiff', '-r300')

volumeViewer(Mito_image_3D)