function [] = imprimir_resultados(subbanda,nivel,Hz1, std)

    for i = 1:4

        switch nivel
            case 1
                fprintf('  Subbanda %d:\n', i);
            case 2
                fprintf('  Subbanda %d.%d:\n',subbanda, i);
            case 3
                fprintf('  Subbanda %d.%d.%d:\n', subbanda(1), subbanda(2), i);
            otherwise
                fprintf('  Subbanda %d:\n', i);
        end

        fprintf('    Entropia Z %.4f\n', Hz1(i));
        fprintf('    Desviación estandar:  %.4f\n\n', std(i));
    end

end