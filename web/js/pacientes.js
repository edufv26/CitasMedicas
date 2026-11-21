/* 
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/JavaScript.js to edit this template
 */

document.addEventListener("DOMContentLoaded", function () {
    const inputBuscar = document.getElementById("fPacBuscar");
    const selectDoctor = document.getElementById("fPacDoctor");
    const btnFiltrar = document.getElementById("btnFiltrarPacientes");
    const btnLimpiar = document.getElementById("btnLimpiarPacientes");
    const tbody = document.querySelector(".tabla-clinica tbody");
    const contenedorTabla = document.querySelector(".table-responsive");
    const filas = tbody
        ? Array.from(tbody.querySelectorAll("tr")).filter(tr => tr.querySelectorAll("td").length >= 6)
        : [];

    // Calcular columnas del encabezado para el colspan
    const thCount = document.querySelectorAll(".tabla-clinica thead th").length;
    const colspanSinResultados = thCount > 0 ? thCount : 7;

    // Crear fila dinámica para estado "sin coincidencias"
    let filaSinResultados = null;
    if (tbody) {
        filaSinResultados = document.createElement("tr");
        filaSinResultados.id = "filaSinCoincidenciasPacientes";
        filaSinResultados.className = "fila-vacia-filtro";
        filaSinResultados.style.display = "none";

        const celda = document.createElement("td");
        celda.colSpan = colspanSinResultados;
        celda.textContent = "No hay pacientes que coincidan con el filtro.";

        filaSinResultados.appendChild(celda);
        tbody.appendChild(filaSinResultados);
    }

    // Poblar opciones únicas de "Doctor Asignado" (columna índice 5)
    if (selectDoctor) {
        const doctoresSet = new Set();
        filas.forEach(fila => {
            if (fila.cells.length >= 6) {
                const docTexto = fila.cells[5].textContent.trim();
                if (docTexto) {
                    doctoresSet.add(docTexto);
                }
            }
        });
        Array.from(doctoresSet).sort().forEach(doc => {
            const opt = document.createElement("option");
            opt.value = doc.toLowerCase();
            opt.textContent = doc;
            selectDoctor.appendChild(opt);
        });
    }

    function filtrarPacientes() {
        const textoBuscado = (inputBuscar ? inputBuscar.value : "").trim().toLowerCase();
        const docBuscado = (selectDoctor ? selectDoctor.value : "").trim().toLowerCase();
        let visibles = 0;

        filas.forEach(fila => {
            if (fila.cells.length < 6) {
                return;
            }

            // Revisa ID (0), Nombre (1), Teléfono (2), Correo (3) y Dirección (4)
            const textoGeneral = [
                fila.cells[0]?.textContent || "",
                fila.cells[1]?.textContent || "",
                fila.cells[2]?.textContent || "",
                fila.cells[3]?.textContent || "",
                fila.cells[4]?.textContent || ""
            ].join(" ").toLowerCase();

            const docCol = (fila.cells[5]?.textContent || "").toLowerCase();

            const okTexto = !textoBuscado || textoGeneral.includes(textoBuscado);
            const okDoc = !docBuscado || docCol === docBuscado;

            fila.classList.remove("fila-filtrada");
            if (okTexto && okDoc) {
                fila.style.display = "";
                visibles++;
            } else {
                fila.style.display = "none";
                fila.style.animationDelay = "0ms";
            }
        });

        let delayIdx = 0;
        filas.forEach(fila => {
            if (fila.style.display !== "none") {
                fila.style.animationDelay = `${Math.min(delayIdx * 25, 200)}ms`;
                void fila.offsetWidth;
                fila.classList.add("fila-filtrada");
                delayIdx++;
            }
        });

        if (filaSinResultados) {
            const mostrarVacia = filas.length > 0 && visibles === 0;
            filaSinResultados.classList.remove("fila-filtrada");
            filaSinResultados.style.display = mostrarVacia ? "" : "none";
            if (mostrarVacia) {
                filaSinResultados.style.animationDelay = "0ms";
                void filaSinResultados.offsetWidth;
                filaSinResultados.classList.add("fila-filtrada");
            }
        }

        if (contenedorTabla) {
            contenedorTabla.classList.remove("filtrando");
            void contenedorTabla.offsetWidth;
            contenedorTabla.classList.add("filtrando");
        }
    }

    if (btnFiltrar) {
        btnFiltrar.addEventListener("click", filtrarPacientes);
    }

    if (btnLimpiar) {
        btnLimpiar.addEventListener("click", function () {
            if (inputBuscar) inputBuscar.value = "";
            if (selectDoctor) selectDoctor.value = "";
            filtrarPacientes();
        });
    }
});