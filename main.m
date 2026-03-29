clear all
pkg load ga
rng(42);  % Исправлено для Octave

printf("\n========== ГЕНЕТИЧЕСКИЙ АЛГОРИТМ (50 ТОВАРОВ) ==========\n\n");

% ========== ДАННЫЕ ==========
n_items = 50;

names = {
    'Яблоки', 'Бананы', 'Апельсины', 'Груши', 'Киви',
    'Мандарины', 'Виноград', 'Ананас', 'Арбуз', 'Дыня',
    'Картофель', 'Морковь', 'Лук', 'Чеснок', 'Капуста',
    'Рис', 'Гречка', 'Овсянка', 'Макароны', 'Мука',
    'Сахар', 'Соль', 'Молоко', 'Кефир', 'Сметана',
    'Творог', 'Сыр', 'Масло', 'Яйца', 'Курица',
    'Говядина', 'Свинина', 'Рыба', 'Колбаса', 'Хлеб',
    'Кофе', 'Чай', 'Шоколад', 'Печенье', 'Орехи',
    'Мёд', 'Варенье', 'Сок', 'Вода', 'Газировка',
    'Шампунь', 'Мыло', 'Зубная паста', 'Бумага', 'Пакеты'
};

% Цены (1 строка, 50 элементов)
prices = [150, 180, 220, 200, 350, 250, 300, 450, 50, 80, 40, 50, 30, 80, 60, 90, 110, 70, 80, 50, 60, 20, 90, 100, 150, 200, 400, 250, 120, 300, 500, 450, 350, 280, 70, 600, 200, 150, 100, 500, 400, 180, 120, 30, 50, 200, 80, 100, 150, 50];

% Минимум (1 строка, 50 элементов)
lb = [5, 4, 3, 4, 2, 5, 3, 1, 10, 5, 20, 10, 10, 5, 10, 10, 8, 10, 10, 15, 10, 5, 20, 15, 10, 5, 3, 5, 30, 10, 5, 5, 5, 5, 20, 3, 5, 5, 10, 3, 2, 5, 10, 30, 10, 3, 5, 5, 10, 20];

% Максимум (1 строка, 50 элементов)
ub = [15, 12, 10, 12, 8, 15, 10, 5, 30, 20, 50, 30, 30, 15, 30, 30, 25, 30, 30, 40, 25, 15, 50, 40, 25, 15, 10, 15, 100, 30, 15, 15, 15, 15, 50, 10, 15, 15, 25, 10, 8, 15, 30, 100, 30, 10, 15, 15, 30, 50];


variants = ub - lb + 1     % Вектор из 50 чисел
##total = prod(variants);      % Их произведение = общее число комбинаций

% Проверка размеров (должно быть 1x50)
printf("Размер prices: %s\n", mat2str(size(prices)));
printf("Размер lb:     %s\n", mat2str(size(lb)));
printf("Размер ub:     %s\n", mat2str(size(ub)));

max_possible = sum(ub .* prices);
budget = floor(max_possible * 0.6);

printf("Бюджет: %d руб (из макс. возможного %d)\n\n", budget, max_possible);

% ========== ПАРАМЕТРЫ ГА ==========
pop_size = 300;
generations = 500;

% ========== ЦЕЛЕВАЯ ФУНКЦИЯ ==========
function val = my_fitness(x, prices, lb, ub, budget)
    x_rounded = round(x);
    x_rounded = max(x_rounded, lb);  % Теперь размеры совпадают (1x50)
    x_rounded = min(x_rounded, ub);
    total = sum(x_rounded .* prices);
    if total > budget
        val = 1e9 + (total - budget);
    else
        val = budget - total;
    end
end

fitness_fcn = @(x) my_fitness(x, prices, lb, ub, budget);

% ========== НАСТРОЙКИ ==========
options = gaoptimset();
options.Generations = generations;
options.PopulationSize = pop_size;
options.Display = 'iter';

% ========== ЗАПУСК ==========
printf("Запуск оптимизации...\n");
tic;
[x_opt, fval] = ga(fitness_fcn, n_items, [], [], [], [], lb, ub, [], options);
time_taken = toc;

% ========== РЕЗУЛЬТАТ ==========
x_final = round(x_opt);
x_final = max(x_final, lb);
x_final = min(x_final, ub);
total = sum(x_final .* prices);
used_budget_percent = (total / budget) * 100;

printf("\n============================================================\n");
printf("РЕЗУЛЬТАТ (Время: %.2f сек)\n", time_taken);
printf("============================================================\n");

[sorted_costs, sort_idx] = sort(x_final .* prices, 'descend');

printf("\nТоп-15 товаров по затратам:\n");
printf("№    Товар          Кол-во  Цена    Сумма\n");
printf("------------------------------------------------------------\n");
for i = 1:min(15, n_items)
    idx = sort_idx(i);
    if x_final(idx) > 0
        printf("%2d.  %-15s  %4d    %4d    %6d руб\n", ...
               i, names{idx}, x_final(idx), prices(idx), x_final(idx)*prices(idx));
    end
end

printf("------------------------------------------------------------\n");
printf("ВСЕГО ТОВАРОВ:     %d позиций\n", n_items);
printf("ИТОГО ЗАТРАТЫ:     %d руб\n", total);
printf("БЮДЖЕТ:            %d руб\n", budget);
printf("ОСТАТОК:           %d руб\n", budget - total);
printf("ИСПОЛЬЗОВАНО:      %.2f%%\n", used_budget_percent);
printf("============================================================\n");

