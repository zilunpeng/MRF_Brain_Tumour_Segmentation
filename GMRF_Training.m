%% 2 cliques
%% only using neighbors in the same slice
function [intensity_given_cls_mean, intensity_given_cls_cov, id_given_two_cls_mean, id_given_two_cls_cov, co_occ] = GMRF_Training(image_numbers, option, three_clique)
    threshold = 0.85; % prob>threshold are considered valid
    num_tumor_cls = 4;
    num_healty_cls = 3; %wm gm csf
    num_cls = num_tumor_cls + num_healty_cls; % patient image = wm, gm, csf + 4 classes; synthetic image = wm, gm, csf + 2 classes
    num_features = 4; % 4 features (flair, t1, t1c, t2)
    if strcmp(option,'2-clique-only')
        num_neighbors = 8; % every center vx has 8 neighbors
    else
        num_neighbors = 10; % plus the vx in the slice above the below.
    end
    
    %% Initialize parameters of GMRF
    intensity_given_cls_mean = zeros(num_cls, num_features);
    intensity_given_cls_cov = zeros(num_features, num_features, num_cls);
    intensity_given_cls_counter = zeros(num_cls, 1);
    
    id_given_two_cls_mean = zeros(num_cls*num_cls, num_features);
    id_given_two_cls_cov = zeros(num_features, num_features, num_cls*num_cls);
    id_given_two_cls_counter = zeros(num_cls*num_cls, 1);
    
    if three_clique
        id_given_three_cls_mean = zeros(num_cls^3, num_features*2);
        id_given_three_cls_cov = zeros(num_features*2,num_features*2, num_cls^3);
        id_given_three_cls_counter = zeros(num_cls^3, 1);
    end
        
    for i=1:length(image_numbers)
        % Form intensity vector
        img_no = image_numbers(i);
        [intensity_mat, ~, numRows, numCols, numSlices] = get_vx_intensity(img_no);
        center_idx = get_center_idx(numRows, numCols, numSlices);
        [center_vx_intensity, neighbor_id] = get_center_ngbr_vx_intensity(intensity_mat, center_idx, numRows, numCols);
        ngbr_vx_idx = get_neighbor_vx_idx(center_idx, numRows, numCols);
        [ground_truth_center_vx, ground_truth_neighbor_vx] = get_ground_truth_label(img_no, center_idx, ngbr_vx_idx);
        [healthy_prob_center_vx, healthy_prob_neighbor_vx] = get_vx_class_prob(img_no, center_idx, ngbr_vx_idx);
        
        %I given C
        for x=1:num_tumor_cls
            [~, idx_oi] = find(ground_truth_center_vx==x);
            intensity = center_vx_intensity(:,idx_oi);
            [intensity_given_cls_mean(x,:), intensity_given_cls_cov(:,:,x), intensity_given_cls_counter(x)] = update_mean_cov_counter(intensity_given_cls_mean(x,:), intensity_given_cls_cov(:,:,x), intensity_given_cls_counter(x), intensity);
        end
        
        for x=1:num_healty_cls
            prob = healthy_prob_center_vx(x,:);
            [~, idx_oi] = find(prob > threshold);
            intensity = center_vx_intensity(:,idx_oi);
            [intensity_given_cls_mean(x+num_tumor_cls,:),intensity_given_cls_cov(:,:,x+num_tumor_cls),intensity_given_cls_counter(x+num_tumor_cls)] = update_mean_cov_counter(intensity_given_cls_mean(x+num_tumor_cls,:),intensity_given_cls_cov(:,:,x+num_tumor_cls),intensity_given_cls_counter(x+num_tumor_cls), intensity);           
        end
        
        %I1-I2 given C1, C2
        for x=1:num_cls
            for y=1:num_cls
                for n=1:num_neighbors
                    prob = healthy_prob_neighbor_vx{n};
                    if x<=num_tumor_cls && y<=num_tumor_cls
                        [~, idx_oi] = find(ground_truth_center_vx == x & ground_truth_neighbor_vx{n} == y);
                    elseif x>num_tumor_cls && y<=num_tumor_cls
                        [~, idx_oi] = find(healthy_prob_center_vx(x-num_tumor_cls,:)>threshold & ground_truth_neighbor_vx{n} == y);
                    elseif x<=num_tumor_cls && y>num_tumor_cls
                        [~, idx_oi] = find(ground_truth_center_vx == x & prob(y-num_tumor_cls,:)>threshold);
                    elseif x>num_tumor_cls && y>num_tumor_cls
                        [~, idx_oi] = find(healthy_prob_center_vx(x-num_tumor_cls,:)>threshold & prob(y-num_tumor_cls,:)>threshold);
                    end
                    intensity = neighbor_id{n};
                    intensity = intensity(:,idx_oi);
                    ind = sub2ind([num_cls,num_cls],y,x);
                    [id_given_two_cls_mean(ind,:),id_given_two_cls_cov(:,:,ind),id_given_two_cls_counter(ind)] = update_mean_cov_counter(id_given_two_cls_mean(ind,:),id_given_two_cls_cov(:,:,ind),id_given_two_cls_counter(ind),intensity);
                end
            end
        end
        
        three_cqe_ngbrs = [1 5;5 3; 3 7;7 2;2 8;8 4;4 6;6 1];
        if three_clique
            for x=1:num_cls
                for y=x:num_cls
                    for z=y:num_cls
                        for n=1:num_neighbors
                            ngbr = three_cqe_ngbrs(n,:);
                            prob = healthy_prob_neighbor_vx{ngbr(1)};
                            prob1 = healthy_prob_neighbor_vx{ngbr(2)};
                            if x<=num_tumor_cls && y<=num_tumor_cls && z<=num_tumor_cls
                                [~, idx_oi] = find(ground_truth_center_vx == x & ground_truth_neighbor_vx{ngbr(1)} == y);
                                [~, idx_oi1] = find(ground_truth_center_vx == x & ground_truth_neighbor_vx{ngbr(2)} == z);
                            elseif x<=num_tumor_cls && y<=num_tumor_cls && z>num_tumor_cls
                                [~, idx_oi] = find(ground_truth_center_vx == x & ground_truth_neighbor_vx{ngbr(1)} == y);
                                [~, idx_oi1] = find(ground_truth_center_vx == x & prob1(z-num_tumor_cls,:)>threshold);
                            elseif x<=num_tumor_cls && y>num_tumor_cls && z<=num_tumor_cls
                                [~, idx_oi] = find(ground_truth_center_vx == x & prob{y-num_tumor_cls,:}>threshold);
                                [~, idx_oi1] = find(ground_truth_center_vx == x & ground_truth_neighbor_vx{ngbr(2)} == z); 
                            elseif x<=num_tumor_cls && y>num_tumor_cls && z>num_tumor_cls
                                [~, idx_oi] = find(ground_truth_center_vx == x & prob{y-num_tumor_cls,:}>threshold);
                                [~, idx_oi1] = find(ground_truth_center_vx == x & prob1(z-num_tumor_cls,:)>threshold);
                            elseif x>num_tumor_cls && y<=num_tumor_cls && z<=num_tumor_cls
                                [~, idx_oi] = find(healthy_prob_center_vx(x-num_tumor_cls,:)>threshold & ground_truth_neighbor_vx{ngbr(1)} == y);
                                [~, idx_oi1] = find(healthy_prob_center_vx(x-num_tumor_cls,:)>threshold & ground_truth_neighbor_vx{ngbr(2)} == z);
                            elseif x>num_tumor_cls && y<=num_tumor_cls && z>num_tumor_cls
                                [~, idx_oi] = find(healthy_prob_center_vx(x-num_tumor_cls,:)>threshold & ground_truth_neighbor_vx{ngbr(1)} == y);
                                [~, idx_oi1] = find(healthy_prob_center_vx(x-num_tumor_cls,:)>threshold & prob1(z-num_tumor_cls,:)>threshold);
                            elseif x>num_tumor_cls && y>num_tumor_cls && z<=num_tumor_cls
                                [~, idx_oi] = find(healthy_prob_center_vx(x-num_tumor_cls,:)>threshold & prob{y-num_tumor_cls,:}>threshold);
                                [~, idx_oi1] = find(healthy_prob_center_vx(x-num_tumor_cls,:)>threshold & ground_truth_neighbor_vx{ngbr(2)} == z);
                            elseif x>num_tumor_cls && y>num_tumor_cls && z>num_tumor_cls
                                [~, idx_oi] = find(healthy_prob_center_vx(x-num_tumor_cls,:)>threshold & prob{y-num_tumor_cls,:}>threshold );
                                [~, idx_oi1] = find(healthy_prob_center_vx(x-num_tumor_cls,:)>threshold & prob1(z-num_tumor_cls,:)>threshold);                            
                            end
                            intensity1 = neighbor_id{ngbr(1)};
                            intensity2 = neighbor_id{ngbr(2)};
                            intensity1 = intensity1(:, idx_oi);
                            intensity2 = intensity2(:, idx_oi1);
                            ind = sub2ind([num_cls,num_cls,num_cls],x,y,z);
                            [id_given_two_cls_mean(ind,:),id_given_two_cls_cov(:,:,ind),id_given_two_cls_counter(ind)] = update_mean_cov_counter(id_given_two_cls_mean(ind,:),id_given_two_cls_cov(:,:,ind),id_given_two_cls_counter(ind),[intensity1, intensity2]);                            
                        end
                    end
                end
            end
        end
    end
    
    %% Normalize
    [intensity_given_cls_mean, intensity_given_cls_cov] = finalize_mean_cov(intensity_given_cls_mean, intensity_given_cls_cov, intensity_given_cls_counter, num_features, num_cls);
    [id_given_two_cls_mean, id_given_two_cls_cov] = finalize_mean_cov(id_given_two_cls_mean, id_given_two_cls_cov, id_given_two_cls_counter, num_features, num_cls);
    if three_clique
        [id_given_three_cls_mean, id_given_three_cls_cov] = finalize_mean_cov(id_given_three_cls_mean, id_given_three_cls_cov, id_given_three_cls_counter, num_features, num_cls);
    end
    
    %% Create co-occurence matrix
    co_occ = reshape(id_given_two_cls_counter/(0.5*sum(id_given_two_cls_counter)), [num_cls,num_cls]);
    
    %% Output
    if three_clique
        GMRF_params = struct('igc_mean',intensity_given_cls_mean,'igc_cov',intensity_given_cls_cov,'id_twoCls_mean',id_given_two_cls_mean,'id_twoCls_cov',id_given_two_cls_cov,'id_treCls_mean',id_given_three_cls_mean,'id_treCls_cov',id_given_three_cls_cov ,'co_occ',co_occ);        
    else
        GMRF_params = struct('igc_mean',intensity_given_cls_mean,'igc_cov',intensity_given_cls_cov,'id_twoCls_mean',id_given_two_cls_mean,'id_twoCls_cov',id_given_two_cls_cov,'co_occ',co_occ);
    end
end