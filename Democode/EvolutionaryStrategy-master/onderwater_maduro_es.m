function [xopt, fopt] = onderwater_maduro_es(eval_budget)
    LocalLearningRate = 1/sqrt(2*sqrt(30));
    GlobalLearningRate = 1/sqrt(2*30);
    xopt = 1000;
    fopt = 1000;
    
    %when we know optimal combination
    simulations = 2;
    population_size = 1; 
    lambda = 3;     
    generations = floor( (eval_budget - population_size ) / lambda );
    averageFitnessParentsSimulationsEvolution = zeros(generations,simulations);
    
    muLambdaSimulations = zeros(simulations,2);
    minFopt = 999999999999;
    minimumFitnessSimulations = zeros(simulations,1);
     
    %when we know optimal parameters
    for i=1:simulations
     
        %helps with testing
        if generations <= 0
            generations = 5;
        end
         
        t = 1;
        population = initialize(population_size);
        fitnessEvolution = zeros(generations,1);
        individualParameterStepsizes = rand(population_size, 30);
        while (t <= generations)
            [offsprings1, individualParameterStepsizesOffspring1] = recombine(population, lambda, individualParameterStepsizes);
            [offsprings2, individualParameterStepsizesOffspring2] = mutate(offsprings1,LocalLearningRate,GlobalLearningRate,individualParameterStepsizesOffspring1);
            [population, tempFopt, tempXopt, individualParameterStepsizes] = select(population, offsprings2, individualParameterStepsizes, individualParameterStepsizesOffspring2);
            fitnessEvolution(t) = tempFopt;
            %when we know optimal parameters
            averageFitnessParentsSimulationsEvolution(t,i) = tempFopt;
            if (tempFopt < fopt)
                fopt = tempFopt;
                xopt = tempXopt;
            end
            
            t = t + 1;
        end
        
        muLambdaSimulations(i, :) = [population_size lambda];
        minimumFitnessSimulations(i) = fopt;
        if fopt < minFopt
            minFopt = fopt;
        end
    end
end

function population = initialize(population_size)
    parameters = 30;
    population = rand(population_size, parameters);
end

function [mutatedOffsprings, newIndividualParameterStepSizes] = mutate(offsprings,LocalMutationRate,GlobalMutationRate,individualParameterStepsizes)
    mutatedOffsprings = offsprings;
    amountOffsprings  = size(offsprings, 1);
    sizeOffspring = 30;
    newIndividualParameterStepSizes = individualParameterStepsizes;
    
    bitMutations = randi(30);
    
    for i=1:amountOffsprings
        randomOffspringIndex = randi(amountOffsprings);
        currentOffspring = offsprings(randomOffspringIndex,:);
        for j=1:bitMutations
            randomMutationIndex = randi(sizeOffspring);
            uniformNegativePositiveValue1 = normrnd(0, 1);
            uniformNegativePositiveValue2 = normrnd(0, 1);
            uniformNegativePositiveValue3 = normrnd(0, 1);

            currentStepSize = individualParameterStepsizes(i, randomMutationIndex);
            newStepSize = currentStepSize + exp(GlobalMutationRate * uniformNegativePositiveValue1 + LocalMutationRate * uniformNegativePositiveValue2);  
            newIndividualParameterStepSizes(i, randomMutationIndex) = double(newStepSize); 
            newParameterValue = currentOffspring(randomMutationIndex) + newStepSize * uniformNegativePositiveValue3;
            %search domain
            if newParameterValue > 10000
                newParameterValue = 10000;
            end
            if newParameterValue < 0
                newParameterValue = 0;
            end
            
            mutatedOffspring = currentOffspring;
            mutatedOffspring(randomMutationIndex) = newParameterValue;
            
        end
        mutatedOffsprings(randomOffspringIndex,:) = mutatedOffspring;
    end
end

function [allOffsprings, individualParameterStepsizesOffsprings] = recombine(population,lambda, individualParameterStepsizes)
    maximumParents = size(population,1); %maximum all parents used for recombination 
    sizeParent = 30;
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
            
            average = totalIndividualParameterRecombined/X;   %average for this parameters
            averageStepsize = totalIndividualStepsizeRecombined/X;
            
            newOffspring(j) = average;
            newOffspringStepsizes(j) = averageStepsize;
        end 
        allOffsprings(i,:) = newOffspring;  %add new offspring to all offspring (listoflists)
        individualParameterStepsizesOffsprings(i, :) = newOffspringStepsizes;
    end
end

function [population,fopt,xopt, individualParameterStepsizes]  = select(population, offsprings, individualParameterStepsizes, individualParameterStepsizesOffsprings)
    pop_size       = size(population,1); 
    countOffsprings = size(offsprings,1);
    format long
        
    fitnessPopulation = zeros(pop_size,1);
    individualParameterStepsizes = population;
    
    % Calculate fitness values for all offsprings.
    allOffspringFitnesses = zeros(countOffsprings,1);
    for i = 1:countOffsprings
        currentOffspring = offsprings(i, :);
        allOffspringFitnesses(i) = str2double( optical( currentOffspring ) );
    end
    maxValueFitness = 999999999999999; 
    
    for j = 1:pop_size
        [minimumFitnessValue,indexCurrentMinimumFitnessValue] = min(allOffspringFitnesses);
        population(j,:) = offsprings(indexCurrentMinimumFitnessValue,:);
        individualParameterStepsizes(j,:) = individualParameterStepsizesOffsprings(indexCurrentMinimumFitnessValue,:);
        fitnessPopulation(j) = minimumFitnessValue;
        allOffspringFitnesses(indexCurrentMinimumFitnessValue) = maxValueFitness;
    end  
    [fopt, xoptInd] = min(fitnessPopulation);
    xopt = population(xoptInd, :);
end