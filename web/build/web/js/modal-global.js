/* 
 - Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 - Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/JavaScript.js to edit this template
 */
document.addEventListener("DOMContentLoaded", () => {

    const esModuloPersonal = () => {
        return Boolean(document.getElementById("seccion-dentista") || document.getElementById("passUsuario"));
    };

    // Función auxiliar para manejar el cierre con animación de salida (Fade Out)
    const cerrarModalAnimado = (modal) => {
        if (!modal || modal.classList.contains("cerrando"))
            return; // Evita clics dobles
        modal.classList.add("cerrando");

        // Espera a que termine la animación (250ms) antes de llamar al .close() nativo
        setTimeout(() => {
            modal.classList.remove("cerrando");
            if (typeof modal.close === "function") {
                modal.close();
            } else {
                modal.removeAttribute("open");
            }
        }, 250);
    };

    // Helper para enlazar cierre con botón o clic fuera (backdrop)
    const vincularCierreModal = (modal) => {
        if (!modal || modal.dataset.cierreVinculado === "true")
            return;
        modal.dataset.cierreVinculado = "true";

        modal.querySelectorAll("[data-cerrar], .btn-cerrar-modal").forEach(btn => {
            btn.addEventListener("click", () => {
                if (modal.id === "modalPassword" && typeof resetModalPassword === "function") {
                    resetModalPassword();
                }
                cerrarModalAnimado(modal);
            });
        });

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
                    const btnSubmit = modal.querySelector('button[type="submit"]');

                    if (esModuloPersonal()) {
                        const inputUsuario = modal.querySelector('#usuario');
                        if (titulo)
                            titulo.textContent = "Nuevo Personal";
                        if (inputAccion)
                            inputAccion.value = "registrarPersonal";
                        if (inputUsuario)
                            inputUsuario.readOnly = false;

                        modal.querySelectorAll('input[type="text"], input[type="password"], input[type="tel"], input[type="email"]').forEach(input => {
                            if (input.name !== "accion") {
                                input.value = "";
                            }
                        });

                        const selectTipo = modal.querySelector('#tipo');
                        if (selectTipo)
                            selectTipo.value = "";

                        const turnoDen = modal.querySelector('#turnoDentista');
                        if (turnoDen)
                            turnoDen.value = "Matutino";

                        const turnoSec = modal.querySelector('#turnoSecretaria');
                        if (turnoSec)
                            turnoSec.value = "Matutino";

                        if (typeof mostrarCamposExtra === "function") {
                            mostrarCamposExtra();
                        }
                    } else {
                        const inputId = modal.querySelector('input[name="idP"]');
                        if (titulo)
                            titulo.textContent = "Nuevo Paciente";
                        if (inputAccion)
                            inputAccion.value = "registrar";
                        if (btnSubmit)
                            btnSubmit.textContent = "Guardar Paciente";
                        if (inputId)
                            inputId.remove();

                        modal.querySelectorAll('input[type="text"], input[type="tel"], input[type="email"]').forEach(input => {
                            input.value = "";
                        });

                        const contenedorSelect = modal.querySelector('select[name="idDenP"]');
                        if (contenedorSelect) {
                            const grupo = contenedorSelect.closest('.campo-grupo, .campo');
                            if (grupo)
                                grupo.style.display = 'none';
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

    // 2 y 3. Vincular cierre en todos los <dialog> existentes
    document.querySelectorAll("dialog").forEach(modal => {
        vincularCierreModal(modal);
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
            if (contenedorSelect) {
                const grupo = contenedorSelect.closest('.campo-grupo, .campo');
                if (grupo)
                    grupo.style.display = 'block';
            }
        }

        if (typeof modalRegistro.showModal === "function") {
            modalRegistro.showModal();
        } else {
            modalRegistro.setAttribute("open", "");
        }
    }

    // 4.5. Apertura automática por servidor para mensajes de respuesta (alta / edición / baja)
    const mensajeServidor = document.body.getAttribute("data-mensaje-respuesta");
    if (mensajeServidor && mensajeServidor.trim() !== "") {
        let modalResp = document.getElementById("modalRespuesta");

        if (!modalResp) {
            modalResp = document.createElement("dialog");
            modalResp.id = "modalRespuesta";
            modalResp.className = "modal-dialog modal-respuesta";
            modalResp.innerHTML = `
                <div class="modal-header">
                    <h3><span class="fa fa-info-circle"></span> Aviso</h3>
                    <button type="button" data-cerrar class="modal-btn-cerrar">&times;</button>
                </div>
                <p class="modal-texto" id="textoModalRespuesta"></p>
                <div class="modal-acciones">
                    <button type="button" data-cerrar class="btn-accion-principal">Aceptar</button>
                </div>
            `;
            document.body.appendChild(modalResp);
        }

        vincularCierreModal(modalResp);

        const pTexto = modalResp.querySelector("#textoModalRespuesta") || modalResp.querySelector(".modal-texto");
        if (pTexto) {
            pTexto.textContent = mensajeServidor;
        }

        document.body.removeAttribute("data-mensaje-respuesta");

        if (typeof modalResp.showModal === "function") {
            modalResp.showModal();
        } else {
            modalResp.setAttribute("open", "");
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
    if (link && link.href && !link.getAttribute("href").startsWith("#") && !link.getAttribute("target") && !link.classList.contains("btn-icon-tabla")) {
        const contenedor = document.querySelector(".container-contenido");
        if (contenedor && !contenedor.classList.contains("saliendo")) {
            e.preventDefault();
            contenedor.classList.add("saliendo");

            setTimeout(() => {
                window.location.href = link.href;
            }, 220);
        }
    }
});