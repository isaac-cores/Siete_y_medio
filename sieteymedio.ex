defmodule SieteYMedio do
    @moduledoc """
    Este módulo implementa el juego "Siete y medio", también conocido
    como "Siete y media". Esta implementación permite la participación
    de exactamente 2 jugadores.

    + Cómo se juega al "Siete y medio":

        El objetivo es conseguir la cifra de 7.5 o acercase lo máximo
        posible. Las cartas del 1 al 7 valen lo mismo que su número y
        las cartas sota, caballo y rey valen 0.5 puntos.

        Al comienzo de partida se reparte una carta bocaarriba a cada
        jugador.

        En cada turno el jugador puede elegir entre pedir una
        carta o plantarse y quedarse con la puntuación que ha conseguido.

        La partida termina cuando finalice el turno del último jugador.
        Una vez finalizada la partida se realiza el recuento de
        puntuación. El ganador es la persona que más se acerce al 7.5 y
        las personas que sobrepasen la cifra pierden automáticamente.
        Puede haber más de un ganador o puede darse el caso de que
        nadie gane.

    + Funcionamiento del módulo:

        La partida es representada mediante la tupla
        "{fase de la partida, lista de jugadores, baraja}" y esta tupla
        se va actualizando acorde con el transcurso de la partida.

        -"fase de la partida":

           -":creación": en esta fase se crean los jugadores, la baraja y
           se reparten las cartas iniciales.

           -"{:jugando, jugador turno actual}": fase en la que los
           jugadores pueden jugar. "jugador turno actual" es un átomo
           que representa al jugador del turno actual.

           -"{:finalizada, jugador ganador}": la partida ha terminado.
           "jugador ganador" puede ser el átomo del ganador o
           una lista de átomos de los ganadores.

        -"lista de jugadores":

            Lista de átomos que representan los jugadores de la partida.

        -"baraja":

            Lista de 40 tuplas "{numero, palo. estado de la carta}".
            Importante: el orden de la lista nunca cambia y se accede
            a la lista de forma aleatoria.

            -"numero": átomo con el número de la carta.

            -"palo": átomo con el palo de la carta.

            -"estado de la carta":

                -":mazo": la carta está en el mazo.

                -"jugador": la carta la posee el jugador "jugador".

    """

    # ==================================================================
    # -------------------- Funciones públicas --------------------------
    # ==================================================================

    @doc """
    Función que crea una partida. Una partida consta de la tupla
    {fase de la partida, lista de jugadores, baraja}.
    """
    def crear_partida() do
        {:creacion, [], crear_baraja()}
    end

    @doc """
    Crea un jugador.
    Precondición: no se ha llegado al número máximo (2) de jugadores.
    Postcondición: si se llega al número máximo de jugadores  la partida
    comienza automáticamente.
    """
    # Caso: se llama cuando hay jugador en la partida.
    def crear_jugador({:creacion, [], baraja}) do
        # Insertamos :jugador1 en lista_jugadores
        nueva_lista_jugadores =
        [("jugador" <> (1 |> Integer.to_string()))|> String.to_atom()]
        {:creacion, nueva_lista_jugadores, baraja}
    end

    # Caso: se llama cuando hay jugador en la partida.
    def crear_jugador({:creacion, [jugador], baraja}) do
        # Insertamos :jugador2 en lista_jugadores
        nueva_lista_jugadores =
        [jugador]++[("jugador" <> (2 |> Integer.to_string()))|> String.to_atom()]
        # Como se ha llegado al número máximo de jugadores, la partida
        # comienza automáticamente.
        {{:jugando, jugador}, nueva_lista_jugadores, repartir(nueva_lista_jugadores, baraja)}
    end

    @doc """
    Muestra las cartas de uno o todos los jugadores.
    Se puede llamar a esta función sin importar de quien es el turno.
    Precondición: estamos en la fase ":jugando". Si se quiere ver las
    cartas de un jugador en concreto, este jugador debe estar en
    la lista de jugadores.
    Salida: string con las cartas.
    """
    # Caso: ver las cartas de todos.
    def ver_carta({_, lista_jugadores, baraja}, :todos) do
        # Mostramos las cartas correspondientes.
        aux_ver_carta(baraja, lista_jugadores, [],
        "\n--------------------------" <>
        "\nCartas de " <>
        Atom.to_string(hd(lista_jugadores)))
    end

    # Caso: ver las cartas de un jugador.
    def ver_carta({_, _, baraja}, jugador) do
        # Mostramos las cartas correspondientes.
        aux_ver_carta(baraja, [jugador], [], "")
    end

    @doc """
    El jugador pide una carta y si se pasa de 7.5 puntos se pasa
    al siguiente jugador.
    Precondición: estamos en la fase ":jugando", "jugador" está en
    "lista_jugadores" y es su turno.
    """
    def pedir_carta({fase, lista_jugadores, baraja}, jugador) do
        n = (:rand.uniform(length(baraja))) - 1
        case Enum.at(baraja, n) do
            {numero, palo, :mazo} ->
                # Modificamos el estado de la carta
                nueva_baraja = modificar_elemento_lista(baraja, n, {numero, palo, jugador})
                if calcular_puntuacion_jugador(nueva_baraja, jugador) > 7.5 do
                    # Pasamos al siguiente jugador.
                    siguiente_turno({fase, lista_jugadores, nueva_baraja})
                else
                    # Continua su turno.
                    {fase, lista_jugadores, nueva_baraja}
                end
            {_, _, _} ->
                # La carta la tiene alguien asi que buscamos otra.
                pedir_carta({fase, lista_jugadores, baraja}, jugador)
            end
    end

    @doc """
    El jugador se planta y se pasa al siguiente turno.
    Precondición: estamos en la fase ":jugando" y está función será
    llamada por el jugador que tiene el turno.
    """
    def plantarse({{:jugando, turno}, lista_jugadores, baraja}) do
        siguiente_turno({{:jugando, turno}, lista_jugadores, baraja})
    end

    # ==================================================================
    # -------------------- Funciones privadas --------------------------
    # ==================================================================

    # Crea la baraja.
    defp crear_baraja() do
        [{:uno, :oros, :mazo}, {:dos, :oros, :mazo},
        {:tres, :oros, :mazo}, {:cuatro, :oros, :mazo},
        {:cinco, :oros, :mazo}, {:seis, :oros, :mazo},
        {:siete, :oros, :mazo}, {:sota, :oros, :mazo},
        {:caballo, :oros, :mazo}, {:rey, :oros, :mazo},
        {:uno, :copas, :mazo}, {:dos, :copas, :mazo},
        {:tres, :copas, :mazo}, {:cuatro, :copas, :mazo},
        {:cinco, :copas, :mazo}, {:seis, :copas, :mazo},
        {:siete, :copas, :mazo}, {:sota, :copas, :mazo},
        {:caballo, :copas, :mazo}, {:rey, :copas, :mazo},
        {:uno, :espadas, :mazo}, {:dos, :espadas, :mazo},
        {:tres, :espadas, :mazo}, {:cuatro, :espadas, :mazo},
        {:cinco, :espadas, :mazo}, {:seis, :espadas, :mazo},
        {:siete, :espadas, :mazo}, {:sota, :espadas, :mazo},
        {:caballo, :espadas, :mazo}, {:rey, :espadas, :mazo},
        {:uno, :bastos, :mazo}, {:dos, :bastos, :mazo},
        {:tres, :bastos, :mazo}, {:cuatro, :bastos, :mazo},
        {:cinco, :bastos, :mazo}, {:seis, :bastos, :mazo},
        {:siete, :bastos, :mazo}, {:sota, :bastos, :mazo},
        {:caballo, :bastos, :mazo}, {:rey, :bastos, :mazo},]
    end

    # Función auxiliar de modificar_elemento_lista que permite
    # una implementación con recursividad terminal.
    # Caso: estamos en la posición a modificar.
    defp aux_modificar_elemento_lista([_ | t], indice, nuevo_elemento, indice, nueva_lista) do
        nueva_lista ++ [nuevo_elemento | t]
    end

    # Caso: no estamos en la posición a modificar, por lo tanto seguimos
    # recorriendo la lista.
    defp aux_modificar_elemento_lista([h | t], indice, nuevo_elemento, j, nueva_lista) do
        aux_modificar_elemento_lista(t, indice, nuevo_elemento, j+1, nueva_lista++[h])
    end

    # Función auxiliar de repartir/2
    # Cambia el elemento "lista[índice]" por "nuevo_elemento".
    defp modificar_elemento_lista(lista, indice, nuevo_elemento) do
        aux_modificar_elemento_lista(lista, indice, nuevo_elemento, 0, [])
    end

    # Reparte una carta bocaarriba a todos los jugadores.
    # Bocaarriba implica que todos los jugadores pueden verla mediante
    # el método "ver_carta".
    defp repartir([], baraja) do baraja end

    defp repartir([jugador | lista_jugadores], baraja) do
        n = (:rand.uniform(length(baraja))) - 1
        case Enum.at(baraja, n) do
            {numero, palo, :mazo} -> # Modificamos el estado de la carta
                repartir(lista_jugadores, modificar_elemento_lista(baraja, n, {numero, palo, jugador}))
            {_, _, _} -> # Calculamos otro numero
                repartir([jugador | lista_jugadores], baraja)
        end
    end

    # Función auxiliar de ver_carta/2. Recorre la baraja y guarda en
    # un string las cartas que tiene cada jugador.
    defp aux_ver_carta([], [_ | []], _, string_cartas) do string_cartas end

    defp aux_ver_carta([], [_ | lista_jugador], lista_aux, string_cartas) do
        aux_ver_carta(lista_aux, lista_jugador, [], string_cartas <>
        "\n--------------------------" <>
        "\nCartas de " <>
        Atom.to_string(hd(lista_jugador)))
    end

    defp aux_ver_carta([{numero, palo, jugador} | baraja], [jugador | lista_jugador], lista_aux, string_cartas) do
        aux_ver_carta(baraja, [jugador | lista_jugador], lista_aux,
        string_cartas <>
        "\n  |   " <>
        Atom.to_string(numero) <>
        " de " <>
        Atom.to_string(palo) <>
        "   |\n")
    end

    defp aux_ver_carta([{numero, palo, estado} | baraja], [jugador | lista_jugador], lista_aux, string_cartas) do
        aux_ver_carta(baraja, [jugador | lista_jugador], lista_aux++[{numero, palo, estado}], string_cartas)
    end

    # Precondición: estamos en la fase ":jugando" y "jugador" está en
    # "lista_jugadores".
    defp siguiente_turno({{:jugando, jugador}, lista_jugadores, baraja}) do
        # Obtenemos la posición de jugador en lista_jugadores
        i = Enum.find_index(lista_jugadores, fn x -> x == jugador end)
        if i == (length(lista_jugadores) - 1) do
            # Si es el último jugador terminamos la partida.
            IO.puts("Fin de la partida")
            {{:finalizada, calcular_ganador(baraja, lista_jugadores)}, lista_jugadores, baraja}
        else
            # Si no es el último jugador devolvemos el jugador siguiente.
            siguiente_jugador = Enum.at(lista_jugadores, i + 1)
            {{:jugando, siguiente_jugador}, lista_jugadores, baraja}
        end
    end

    # Devuelve la puntuacion de un carta.
    defp puntuacion_carta(numero_carta) do
        case numero_carta do
            :uno -> 1.0
            :dos -> 2.0
            :tres -> 3.0
            :cuatro -> 4.0
            :cinco -> 5.0
            :seis -> 6.0
            :siete -> 7.0
            :sota -> 0.5
            :caballo -> 0.5
            :rey -> 0.5
        end
    end
    # Recorre la baraja para calcular la puntuación de un jugador.
    # Entrada: la baraja y el jugador del que se calcula la puntuación.
    defp calcular_puntuacion_jugador([], _) do 0.0 end

    defp calcular_puntuacion_jugador([{numero, _, jugador} | baraja], jugador) do
        puntuacion_carta(numero)
        puntuacion_carta(numero) + calcular_puntuacion_jugador(baraja, jugador)
    end

    defp calcular_puntuacion_jugador([_ | baraja], jugador) do
        calcular_puntuacion_jugador(baraja, jugador)
    end

    # puntuaciones/2 es una función auxiliar de calcular_ganador que
    # devuelve una lista con los ganadores.
    # Internamente, crea una lista con las puntuaciones para luego
    # calcular la máxima puntuación con Enum.max/1. También crea
    #una lista de pares {jugador, puntuacion_jugador} y compara
    # puntuacion_jugador con la máxima puntuación.
    # Caso: ya se han terminado todos los cálculos y devolvemos
    # la lista con los ganadores.
    defp puntuaciones(_, [], _, [], salida) do salida end

    # Caso: ya tenemos la lista con las puntuaciones y procedemos a
    # calcular la máxima y compararla con las puntaciones
    # de los jugadores
    defp puntuaciones(baraja, [], lista_puntuaciones, [{jugador, puntuacion} | lista_puntuaciones_jugadores], salida) do
        max_puntuacion = Enum.max(lista_puntuaciones)
        if max_puntuacion < 0 do
            # Si la puntuación es negativa nadie gana.
            salida
        else
            if puntuacion == max_puntuacion do
                puntuaciones(baraja, [], lista_puntuaciones, lista_puntuaciones_jugadores, salida++[{jugador, puntuacion}])
            else
                puntuaciones(baraja, [], lista_puntuaciones, lista_puntuaciones_jugadores, salida)
            end
        end
    end

    # Caso: vamos creando la lista con las puntaciones y la lista
    # con los pares {jugador, puntuacion_jugador}
    defp puntuaciones(baraja, [h | lista_jugadores], lista_puntuaciones, lista_puntuaciones_jugadores, salida) do
        puntuacion = calcular_puntuacion_jugador(baraja, h)
        if puntuacion > 7.5 do
            # Si el jugador se ha pasado del 7.5 le ponemos una puntuación de -1.0
            puntuaciones(baraja, lista_jugadores, lista_puntuaciones++[-1.0], lista_puntuaciones_jugadores++[{h, -1.0}], salida)
        else
            puntuaciones(baraja, lista_jugadores, lista_puntuaciones++[puntuacion], lista_puntuaciones_jugadores++[{h, puntuacion}], salida)
        end
    end

    # Calcula las puntuaciones de todos los jugadores y devuelve una
    # lista con los ganadores.
    def calcular_ganador(baraja, lista_jugadores) do puntuaciones(baraja, lista_jugadores, [], [], []) end
end
