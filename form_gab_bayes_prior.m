function prior = form_gab_bayes_prior(gm_prob, wm_prob, csf_prob, num_tumor_cls, num_healthy_cls)
    num_cls = num_healthy_cls + num_tumor_cls;
    [numRows, numCols] = size(gm_prob);
    prior = zeros(numRows, numCols, num_cls);
    prior(:,:,num_cls-2) = gm_prob;
    prior(:,:,num_cls-1) = wm_prob;
    prior(:,:,num_cls) = csf_prob;
    [temp,~] = max(prior(:,:,num_cls-2:num_cls),[],3);
    %[temp,~] = min(prior(:,:,num_cls-2:num_cls),[],3);
    
    for i=1:num_tumor_cls
       prior(:,:,i) =  temp;
    end
    
    temp = sum(prior,3); %noramalizing constant
    prior = prior ./temp;
end