function [mapa_optimo_nivel1, mapa_optimo_nivel2] = calcular_mapa_energia(ex, mapa1, mapa2)
    % Inicializar mapas óptimos
    mapa_optimo_nivel1 = ones(1, 4);  % Mapa óptimo de nivel 1
    mapa_optimo_nivel2 = ones(4, 4);  % Mapa óptimo de nivel 2

    %% metodo 1 (promedio energia hijas)

    % % Comparación de subbandas de Nivel 1 con subbandas hijas de Nivel 2
    % for k = 1:4
    %     if mapa1(k) == 1
    %         % Calcula el parámetro para la subbanda de Nivel 1
    %         energia_nivel1 = ex{1, 1}(k);
    % 
    %         % Suma de parámetros de subbandas hijas en Nivel 2
    %         energia_hijas_nivel2 = 0;
    %         for kk = 1:4
    %             energia_hijas_nivel2 = energia_hijas_nivel2 + ex{2, k}(kk);
    %         end
    %              energia_hijas_nivel2 = (energia_hijas_nivel2/4);
    %         % Criterio de poda para cada subbanda de Nivel 1 y sus hijas de Nivel 2
    %         if energia_hijas_nivel2 >= energia_nivel1
    %             mapa_optimo_nivel1(k) = 0;  % Poda en el mapa del nivel 1 para la subbanda k
    %         end
    %     end
    % end
    % 
    % % Comparación de subbandas de Nivel 2 con subbandas hijas de Nivel 3
    % for k = 1:4
    %     if mapa_optimo_nivel1(k) == 1  % Solo si la subbanda sigue activa en el nivel 1
    %         for kk = 1:4
    %             if mapa2(k, kk) == 1
    %                 % Calcula el parámetro para la subbanda de Nivel 2
    %                 energia_nivel2 = ex{2, k}(kk);
    % 
    %                 % Suma de parámetros de subbandas hijas en Nivel 3
    %                 energia_hijas_nivel3 = 0;
    %                 for kkk = 1:4
    %                     energia_hijas_nivel3 = energia_hijas_nivel3 + ex{3, k}{kk}(kkk);
    %                 end
    %                 energia_hijas_nivel3 = (energia_hijas_nivel3/4);
    % 
    %                 % Criterio de poda para cada subbanda de Nivel 2 y sus hijas de Nivel 3
    %                 if energia_hijas_nivel3 >= energia_nivel2
    %                     mapa_optimo_nivel2(k, kk) = 0;  % Poda en el mapa del nivel 2 para la subbanda k, kk
    %                 end
    %             end
    %         end
    % 
    %     else
    % 
    %     mapa_optimo_nivel2(k,:) = [0 , 0, 0, 0]
    % 
    %     end
    % end
   
    %% método dos (definir umbral)

    % Comparación de subbandas de Nivel 1 con subbandas hijas de Nivel 2
    for k = 1:4
        if mapa1(k) == 1
            % Calcula el parámetro para la subbanda de Nivel 1
            energia_nivel1 = ex{1, 1}(k);

            % Suma de parámetros de subbandas hijas en Nivel 2
            energia_hijas_nivel2 = 0;
            for kk = 1:4
                energia_hijas_nivel2 = energia_hijas_nivel2 + ex{2, k}(kk);
            end
                 r = energia_nivel1/energia_hijas_nivel2;

            % Criterio de poda para cada subbanda de Nivel 1 y sus hijas de Nivel 2
            if r >= 0.8
                mapa_optimo_nivel1(k) = 0;  % Poda en el mapa del nivel 1 para la subbanda k
            end
        end
    end

    % Comparación de subbandas de Nivel 2 con subbandas hijas de Nivel 3
    for k = 1:4
        if mapa_optimo_nivel1(k) == 1  % Solo si la subbanda sigue activa en el nivel 1
            for kk = 1:4
                if mapa2(k, kk) == 1
                    % Calcula el parámetro para la subbanda de Nivel 2
                    energia_nivel2 = ex{2, k}(kk);

                    % Suma de parámetros de subbandas hijas en Nivel 3
                    energia_hijas_nivel3 = 0;
                    for kkk = 1:4
                        energia_hijas_nivel3 = energia_hijas_nivel3 + ex{3, k}{kk}(kkk);
                    end
                     r = energia_nivel2/energia_hijas_nivel3;

                    % Criterio de poda para cada subbanda de Nivel 2 y sus hijas de Nivel 3
                    if r >= 0.8
                        mapa_optimo_nivel2(k, kk) = 0;  % Poda en el mapa del nivel 2 para la subbanda k, kk
                    end
                end
            end

        else

        mapa_optimo_nivel2(k,:) = [0 , 0, 0, 0]

        end
    end
    %%

    % Mostrar los mapas óptimos obtenidos
    disp('Mapa óptimo para nivel 1:');
    disp(mapa_optimo_nivel1);
    disp('Mapa óptimo para nivel 2:');
    disp(mapa_optimo_nivel2);
end