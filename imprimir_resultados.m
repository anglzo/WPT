function [] = imprimir_resultados(subbanda,nivel,entropias, max_entropia, RH, std, SZ, SZ_RH)

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

        fprintf('    Entropía: %.4f\n', entropias(i));
        fprintf('    Max entropía: %.4f\n', max_entropia(i));
        fprintf('    RH: %.4f\n', RH(i));
        fprintf('    SZ: %d\n', SZ(i));
        fprintf('    SZ * RH: %.4f\n', SZ_RH(i));
        fprintf('    Desviación estandar:  %.4f\n\n', std(i));
    end

end