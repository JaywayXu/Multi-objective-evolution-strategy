function [allOffsprings, individualParameterStepsizesOffsprings] = recombine(population,lambda, individualParameterStepsizes)
    minimumParents = 2;   %atleast 2 needed for recombination
    maximumParents = size(population,1); %maximum all parents used for recombination 
    sizeParent = 30; %length(population(1,:))
    offspringParents = zeros(lambda);
    individualParameterStepsizesOffsprings = zeros(lambda, sizeParent);
    
    allOffsprings = zeros(lambda,sizeParent);
    
    %generate lambda offsprings
    for i=1:lambda
        
        %choose amount of X random parents that will be used for recombination
        X = randi(maximumParents,1);
        
        %choose the indexes of the X random parents that will be used from
        %population for recombination
        Xindexes = randsample(maximumParents,X);
        
        %recombine -> for each parameter take the average out of the X parents
        newOffspring = zeros(sizeParent,1);
        newOffspringStepsizes = zeros(sizeParent, 1);
        for j=1:sizeParent   %amount of parameters
            totalIndividualParameterRecombined = 0;
        	totalIndividualStepsizeRecombined = 0;
            
            for k=1:X       %amount of parents selected
                currentParent = population(Xindexes(k),:); 
                totalIndividualParameterRecombined = totalIndividualParameterRecombined + currentParent(j); 
                currentStepsizesParent = individualParameterStepsizes(Xindexes(k),:);
                totalIndividualStepsizeRecombined = totalIndividualStepsizeRecombined  +  currentStepsizesParent(j);
            end
            
            %X
            average = totalIndividualParameterRecombined/X;   %average for this parameters
            averageStepsize = totalIndividualStepsizeRecombined/X;
            
            newOffspring(j) = average;
            newOffspringStepsizes(j) = averageStepsize;
        end 
        allOffsprings(i,:) = newOffspring;  %add new offspring to all offspring (listoflists)
        individualParameterStepsizesOffsprings(i, :) = newOffspringStepsizes;
    end
end