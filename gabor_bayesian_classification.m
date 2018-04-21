function gab_bayes_prior = gabor_bayesian_classification(img_no,num_gabor_features, gab_output_g_tcls_mean, gab_output_g_tcls_cov, gab_output_g_hcls_mean, gab_output_g_hcls_cov, num_tumor_cls, num_healthy_cls)
    % get healthy tissue probability
    healthy_cls_prob = read_healthy_class_prob(img_no);
    gm_prob = healthy_cls_prob{1};
    wm_prob = healthy_cls_prob{2};
    csf_prob = healthy_cls_prob{3};
    % get flair, T1, T1c, T2 for the testing image
    [flair_data, t1_data, t1c_data, t2_data] = get_MRI_vols(img_no);
    [numRows,numCols,numSlices] = size(flair_data);
    num_px_per_slice = numRows*numCols;
    num_px = num_px_per_slice*numSlices;
    num_cls = num_tumor_cls + num_healthy_cls;
    
    %Initialize
    ml_cls_assign = zeros(numRows,numCols,numSlices);
    gab_bayes_prior = zeros(num_cls, num_px);    
    num_vx_visited = 0;
    %num_vx_visited = 99*num_px_per_slice;
    
    g = gabor_filter(numRows,numCols);
    for slice=1:numSlices %100:100
        cls_lld = zeros(numRows,numCols,num_cls);
        [flair_gabormag, t1_gabormag, t1c_gabormag, t2_gabormag] = apply_gabor_filter_bank(g, flair_data(:,:,slice), t1_data(:,:,slice), t1c_data(:,:,slice), t2_data(:,:,slice));
        gabor_output = [reshape(flair_gabormag,num_px_per_slice,num_gabor_features), reshape(t1_gabormag,num_px_per_slice,num_gabor_features), reshape(t1c_gabormag,num_px_per_slice,num_gabor_features), reshape(t2_gabormag,num_px_per_slice,num_gabor_features)];
        
        % Calculate likelihood
        for i=1:num_tumor_cls
            cls_lld(:,:,i) = reshape(mvnpdf(gabor_output, gab_output_g_tcls_mean(i,:), gab_output_g_tcls_cov(:,:,i)), [numRows, numCols]);
        end
        
        for i=1:num_healthy_cls
            cls_lld(:,:,num_tumor_cls+i) = reshape(mvnpdf(gabor_output, gab_output_g_hcls_mean(i,:), gab_output_g_hcls_cov(:,:,i)), [numRows, numCols]);
        end
               
        % Form prior
        prior = form_gab_bayes_prior(gm_prob(:,:,slice), wm_prob(:,:,slice), csf_prob(:,:,slice), num_tumor_cls, num_healthy_cls);        

%         [~,map_label] = max(posterior,[],3); %keep for debugging
%         map_label(zero_idx) = -1;
%         ml_cls_assign(:,:,slice) = map_label;

        posterior = cls_lld.*prior;
        posterior = posterior./sum(posterior,3);        
        posterior = reshape(posterior, [num_px_per_slice,num_cls]);
        posterior = posterior';
        posterior(posterior==0) = 1e-8;
        gab_bayes_prior(:,num_vx_visited+1:num_vx_visited+num_px_per_slice) = posterior;
        num_vx_visited = num_vx_visited + num_px_per_slice;
    end
end