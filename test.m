clear all
pkg load ga
rng(42);  % Фиксируем случайность (в начале скрипта)

printf("\n========== ИГРАЕМСЯ С ГЕНЕТИЧЕСКИМ АЛГОРИТМОМ ==========\n\n");

% Данные
prices = [150, 300, 1000, 300, 200, 400];
lb = [10, 4, 5, 4, 5, 14];
ub = [20, 7, 8, 7, 8, 15];
budget = 16380;

% Параметры ГА
pop_size = 200;
generations = 300;


% ========== ЦЕЛЕВАЯ ФУНКЦИЯ ==========
% Округляем и принудительно ограничиваем внутри функции
function val = my_fitness(x, prices, lb, ub, budget)
    x_rounded = round(x);
    % Принудительно ограничиваем границами
    x_rounded = max(x_rounded, lb);
    x_rounded = min(x_rounded, ub);
    total = sum(x_rounded .* prices);
    if total > budget
        val = 1e9 + (total - budget);
    else
        val = budget - total;  % минимизируем остаток
    end
end

% Оборачиваем в анонимную функцию
fitness_fcn = @(x) my_fitness(x, prices, lb, ub, budget);

% Настройки
options = gaoptimset();
options.Generations = generations;
options.PopulationSize = pop_size;
options.Display = 'iter';

% ЗАПУСК ГА
[x_opt, fval] = ga(fitness_fcn, 6, [], [], [], [], lb, ub, [], options);

% Корректируем финальный результат
x_final = round(x_opt);
x_final = max(x_final, lb);
x_final = min(x_final, ub);

total = sum(x_final .* prices);

printf("\n============================================================\n");
printf("РЕЗУЛЬТАТ:\n");
printf("============================================================\n");
printf("Яблоки:     %d кг  x %d руб = %d руб\n", x_final(1), prices(1), x_final(1)*prices(1));
printf("Бананы:     %d кг  x %d руб = %d руб\n", x_final(2), prices(2), x_final(2)*prices(2));
printf("Апельсины:  %d кг  x %d руб = %d руб\n", x_final(3), prices(3), x_final(3)*prices(3));
printf("Груши:      %d кг  x %d руб = %d руб\n", x_final(4), prices(4), x_final(4)*prices(4));
printf("Киви:       %d кг  x %d руб = %d руб\n", x_final(5), prices(5), x_final(5)*prices(5));
printf("Мандарины:  %d кг  x %d руб = %d руб\n", x_final(6), prices(6), x_final(6)*prices(6));
printf("------------------------------------------------------------\n");
printf("ИТОГО:             %d руб\n", total);
printf("Бюджет:            %d руб\n", budget);
printf("ОСТАТОК:           %d руб\n", budget - total);
printf("============================================================\n");
