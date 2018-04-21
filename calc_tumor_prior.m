num_imgs = 20;
sizes = zeros(num_imgs, 3);
for i=1:num_imgs
    gt = get_ground_truth(i);
    sizes(i,:) = size(gt);
end
n = 1;