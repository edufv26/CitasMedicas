/* 
- Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
- Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/JavaScript.js to edit this template
 */
document.addEventListener("DOMContentLoaded", () => {
    const loaderVolver = document.getElementById("loading-overlay");
    const overlayGraficas = document.getElementById("overlayGraficas");
    const textoEl = document.getElementById("textoCargaGraficas");
    const subtextoEl = document.getElementById("subtextoCargaGraficas");
    const formularios = document.querySelectorAll("form");

    // Guarda si el botón ya venía bloqueado desde el JSP/Bean (ej. PDF sin gráficas listas)
    document.querySelectorAll("form button[type='submit']").forEach((btn) => {
        btn.dataset.bloqueadoPorEstado = btn.disabled ? "1" : "0";
    });

    function mostrarCargaGraficas(titulo, subtitulo) {
        if (loaderVolver) loaderVolver.classList.remove("active");
        if (!overlayGraficas) return;
        if (textoEl && titulo) textoEl.textContent = titulo;
        if (subtextoEl && subtitulo) subtextoEl.textContent = subtitulo;

        overlayGraficas.setAttribute("aria-hidden", "false");
        overlayGraficas.classList.add("activo");
    }

    function ocultarCargaGraficas() {
        if (!overlayGraficas) return;
        overlayGraficas.classList.remove("activo");
        overlayGraficas.setAttribute("aria-hidden", "true");

        document.querySelectorAll("form button[type='submit']").forEach((btn) => {
            btn.classList.remove("cargando-btn");
            if (btn.dataset.bloqueadoPorEstado !== "1") {
                btn.disabled = false;
            }
        });
    }

    function mostrarCargaVolver() {
        ocultarCargaGraficas();
        if (loaderVolver) {
            loaderVolver.classList.add("active");
        }
    }

    function ocultarTodo() {
        ocultarCargaGraficas();
        if (loaderVolver) {
            loaderVolver.classList.remove("active");
        }
    }

    // 1. Botón de Volver -> usa #loading-overlay (1 segundo)
    document.querySelectorAll("a.btn-secundario").forEach((link) => {
        link.addEventListener("click", (e) => {
            const href = link.getAttribute("href");
            if (!href || href === "#" || href.toLowerCase().startsWith("javascript:")) {
                return;
            }
            if (link.target === "_blank" || e.ctrlKey || e.metaKey || e.shiftKey) {
                return;
            }

            e.preventDefault();
            mostrarCargaVolver();

            setTimeout(() => {
                window.location.href = href;
            }, 1000);
        });
    });

    // 2. Formularios de Gráficas y PDF -> usan #overlayGraficas
    formularios.forEach((form) => {
        form.addEventListener("submit", (e) => {
            const esPdf = form.querySelector("input[name='accion'][value='pdfGraficas']") !== null;
            const botonSubmit = form.querySelector("button[type='submit']");

            if (botonSubmit && botonSubmit.disabled) {
                e.preventDefault();
                return;
            }

            if (botonSubmit) {
                botonSubmit.classList.add("cargando-btn");
                botonSubmit.disabled = true;
            }

            if (esPdf) {
                mostrarCargaGraficas(
                    "Exportando reporte PDF...",
                    "Preparando gráficas y tabla de pacientes"
                );

                // Como la descarga de PDF no recarga la página, ocultamos tras un breve margen
                setTimeout(() => {
                    ocultarCargaGraficas();
                }, 2200);
            } else {
                mostrarCargaGraficas(
                    "Generando gráficas...",
                    "Procesando doctor y periodo seleccionado"
                );
            }
        });
    });

    // Evita que alguno quede pegado si se vuelve desde el historial del navegador
    window.addEventListener("pageshow", () => {
        ocultarTodo();
    });
});