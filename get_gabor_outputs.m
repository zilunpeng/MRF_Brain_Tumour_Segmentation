function [gab_output_g_tcls_mean, gab_output_g_tcls_cov, gab_output_g_hcls_mean, gab_output_g_hcls_cov] = get_gabor_outputs(img_numbers,num_tumor_cls,num_healthy_cls)
    %% Initialize parameters
    threshold = 0.95; %prob>threshold considered valid
    num_gabor_features = 20;
    num_features = 4; %flair, t1, t1c, t2
    gab_output_g_tcls_mean = zeros(num_tumor_cls, num_gabor_features*num_features);
    gab_output_g_tcls_cov = zeros(num_gabor_features*num_features, num_gabor_features*num_features, num_tumor_cls);
    gab_output_tcounter = zeros(num_tumor_cls, 1);
    
    gab_output_g_hcls_mean = zeros(num_healthy_cls, num_gabor_features*num_features);
    gab_output_g_hcls_cov = zeros(num_gabor_features*num_features, num_gabor_features*num_features,num_healthy_cls);
    gab_output_hcounter = zeros(num_healthy_cls, 1);
    
    for i=1:length(img_numbers)
        img_no = img_numbers(i);
        % get ground truth
        ground_truth = get_ground_truth(img_no);
        [numRows,numCols,numSlices] = size(ground_truth);
        num_vx_perSlice = numRows*numCols;
        % get healthy tissue probability
        healthy_cls_prob = read_healthy_class_prob(img_no);
        
        % get flair, T1, T1c, T2
        [flair_data, t1_data, t1c_data, t2_data] = get_MRI_vols(img_no);

        g = gabor_filter(numRows,numCols);
        for slice=1:numSlices
            [flair_gabormag, t1_gabormag, t1c_gabormag, t2_gabormag] = apply_gabor_filter_bank(g, flair_data(:,:,slice), t1_data(:,:,slice), t1c_data(:,:,slice), t2_data(:,:,slice));
            gab_output = [reshape(flair_gabormag,num_vx_perSlice,num_gabor_features), reshape(t1_gabormag,num_vx_perSlice,num_gabor_features), reshape(t1c_gabormag,num_vx_perSlice,num_gabor_features), reshape(t2_gabormag,num_vx_perSlice,num_gabor_features)];
            
            for cls = 1:num_tumor_cls
                [row,col,~] = find(ground_truth(:,:,slice) == cls);
                if ~isempty(row)
                    idx = sub2ind([numRows,numCols], row,col);
                    [gab_output_g_tcls_mean(cls,:), gab_output_g_tcls_cov(:,:,cls), gab_output_tcounter(cls)] = update_mean_cov_counter(gab_output_g_tcls_mean(cls,:), gab_output_g_tcls_cov(:,:,cls), gab_output_tcounter(cls), gab_output(idx,:)');
                end
            end
            
            for cls = 1:num_healthy_cls
                cur_cls = healthy_cls_prob{cls};
                [row,col,~] = find(cur_cls(:,:,slice) >= threshold);
                if ~isempty(row)
                    idx = sub2ind([numRows,numCols], row,col);
                    [gab_output_g_hcls_mean(cls,:), gab_output_g_hcls_cov(:,:,cls), gab_output_hcounter(cls)] = update_mean_cov_counter(gab_output_g_hcls_mean(cls,:), gab_output_g_hcls_cov(:,:,cls), gab_output_hcounter(cls), gab_output(idx,:)');
                end                
            end
        end      
    end
    
    %%Finalize
    [gab_output_g_tcls_mean, gab_output_g_tcls_cov] = finalize_mean_cov(gab_output_g_tcls_mean, gab_output_g_tcls_cov, gab_output_tcounter, num_gabor_features*num_features, num_tumor_cls);
    [gab_output_g_hcls_mean, gab_output_g_hcls_cov] = finalize_mean_cov(gab_output_g_hcls_mean, gab_output_g_hcls_cov, gab_output_hcounter, num_gabor_features*num_features, num_healthy_cls);
end