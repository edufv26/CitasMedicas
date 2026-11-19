/* 
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/JavaScript.js to edit this template
 */
document.addEventListener("DOMContentLoaded", () => {

    const esModuloPersonal = () => {
        return Boolean(document.getElementById("seccion-dentista") || document.getElementById("passUsuario"));
    };

    // Función auxiliar para manejar el cierre con animación de salida (Fade Out)
    const cerrarModalAnimado = (modal) => {
        if (modal.classList.contains("cerrando")) return; // Evita clics dobles
        modal.classList.add("cerrando");

        // Espera a que termine la animación (250ms) antes de llamar al .close() nativo
        setTimeout(() => {
            modal.classList.remove("cerrando");
            modal.close();
        }, 250);
    };

    // 1. Abrir cualquier modal usando el atributo data-abrir
    document.querySelectorAll("[data-abrir]").forEach(btn => {
        btn.addEventListener("click", () => {
            const modalId = btn.getAttribute("data-abrir");
            const modal = document.getElementById(modalId);
            if (modal) {
                if (modalId === "modalRegistro") {
                    const titulo = modal.querySelector("h3");
                    const inputAccion = modal.querySelector('input[name="accion"]');

                    if (esModuloPersonal()) {
                        const inputUsuario = modal.querySelector('#usuario');
                        if (titulo) titulo.textContent = "Nuevo Personal";
                        if (inputAccion) inputAccion.value = "registrarPersonal";
                        if (inputUsuario) inputUsuario.readOnly = false;

                        modal.querySelectorAll('input[type="text"], input[type="password"], input[type="tel"], input[type="email"]').forEach(input => {
                            if (input.name !== "accion") {
                                input.value = "";
                            }
                        });

                        const selectTipo = modal.querySelector('#tipo');
                        if (selectTipo) selectTipo.value = "";

                        const turnoDen = modal.querySelector('#turnoDentista');
                        if (turnoDen) turnoDen.value = "Matutino";

                        const turnoSec = modal.querySelector('#turnoSecretaria');
                        if (turnoSec) turnoSec.value = "Matutino";

                        if (typeof mostrarCamposExtra === "function") {
                            mostrarCamposExtra();
                        }
                    } else {
                        const inputId = modal.querySelector('input[name="idP"]');
                        if (titulo) titulo.textContent = "Nuevo Paciente";
                        if (inputAccion) inputAccion.value = "registrar";
                        if (inputId) inputId.remove();

                        modal.querySelectorAll('input[type="text"], input[type="tel"], input[type="email"]').forEach(input => {
                            input.value = "";
                        });

                        const contenedorSelect = modal.querySelector('select[name="idDenP"]');
                        if (contenedorSelect && contenedorSelect.closest('.campo')) {
                            contenedorSelect.closest('.campo').style.display = 'none';
                        }
                    }
                }

                if (typeof modal.showModal === "function") {
                    modal.showModal();
                } else {
                    modal.setAttribute("open", "");
                }
            }
        });
    });

    // 2. Cerrar cualquier modal usando el botón con clase .btn-cerrar o atributo data-cerrar
    document.querySelectorAll("[data-cerrar], .btn-cerrar-modal").forEach(btn => {
        btn.addEventListener("click", () => {
            const modal = btn.closest("dialog");
            if (modal) {
                if (modal.id === "modalPassword" && typeof resetModalPassword === "function") {
                    resetModalPassword();
                }
                cerrarModalAnimado(modal);
            }
        });
    });

    // 3. Cerrar si hacen clic fuera del cuadro (en el fondo oscuro/backdrop)
    document.querySelectorAll("dialog").forEach(modal => {
        modal.addEventListener("click", (e) => {
            const dims = modal.getBoundingClientRect();
            if (
                e.clientX < dims.left ||
                e.clientX > dims.right ||
                e.clientY < dims.top ||
                e.clientY > dims.bottom
            ) {
                if (modal.id === "modalPassword" && typeof resetModalPassword === "function") {
                    resetModalPassword();
                }
                cerrarModalAnimado(modal);
            }
        });
    });

    // 4. Apertura automática por servidor (para edición)
    const modalRegistro = document.getElementById("modalRegistro");
    if (modalRegistro && modalRegistro.hasAttribute("open")) {
        modalRegistro.removeAttribute("open");

        if (esModuloPersonal()) {
            if (typeof mostrarCamposExtra === "function") {
                mostrarCamposExtra();
            }
        } else {
            const contenedorSelect = modalRegistro.querySelector('select[name="idDenP"]');
            if (contenedorSelect && contenedorSelect.closest('.campo')) {
                contenedorSelect.closest('.campo').style.display = 'block';
            }
        }

        if (typeof modalRegistro.showModal === "function") {
            modalRegistro.showModal();
        } else {
            modalRegistro.setAttribute("open", "");
        }
    }
});

// 5. Función global para disparar el modal de confirmación de eliminación
function abrirModalEliminar(identificador) {
    const modal = document.getElementById("modalEliminar");
    const btnConfirmar = document.getElementById("btnConfirmarEliminar");
    const esPersonal = Boolean(document.getElementById("seccion-dentista") || document.getElementById("passUsuario"));

    if (btnConfirmar) {
        if (esPersonal) {
            btnConfirmar.href = "Control?accion=eliminarPersonal&usuario=" + encodeURIComponent(identificador);
        } else {
            btnConfirmar.href = "Control?accion=eliminar&id=" + identificador;
        }
    }

    if (modal) {
        if (typeof modal.showModal === "function") {
            modal.showModal();
        } else {
            modal.setAttribute("open", "");
        }
    }
}

// 6. Animación de salida fluida al cambiar de vista (ej. Volver)
document.addEventListener("click", function (e) {
    const link = e.target.closest("a");
    // Validamos que sea un enlace de navegación interno y que no abra pestañas nuevas
    if (link && link.href && !link.getAttribute("href").startsWith("#") && !link.getAttribute("target") && !link.classList.contains("btn-icon-tabla")) {
        const contenedor = document.querySelector(".container-contenido");
        if (contenedor && !contenedor.classList.contains("saliendo")) {
            e.preventDefault(); // Frenamos el salto instantáneo
            contenedor.classList.add("saliendo"); // Activamos la animación de salida

            setTimeout(() => {
                window.location.href = link.href; // Navegamos terminando la animación
            }, 220);
        }
    }
});