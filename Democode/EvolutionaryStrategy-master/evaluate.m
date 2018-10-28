function fitness = evaluate(population)
    format long
    pop_size = size(population, 1);
    fitness = zeros(pop_size);
    for i=1:pop_size
        fitness(i) = str2double( optical( population(i, :) ) );
    end
end