/* 
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/JavaScript.js to edit this template
 */
document.addEventListener("DOMContentLoaded", () => {
    
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
                // Si abrimos el modal de registro mediante el botón de Alta:
                if (modalId === "modalRegistro") {
                    const titulo = modal.querySelector("h3");
                    const inputAccion = modal.querySelector('input[name="accion"]');
                    const inputId = modal.querySelector('input[name="idP"]');
                    
                    // Configuramos para Modo Registro (Nuevo Paciente)
                    if (titulo) titulo.textContent = "Nuevo Paciente";
                    if (inputAccion) inputAccion.value = "registrar";
                    if (inputId) inputId.remove(); // Eliminamos el ID oculto de edición si existía
                    
                    // Limpiamos los inputs de texto
                    modal.querySelectorAll('input[type="text"], input[type="tel"], input[type="email"]').forEach(input => {
                        input.value = "";
                    });
                    
                    // Ocultamos el campo de doctor de preferencia (ya que en alta es aleatorio)
                    const contenedorSelect = modal.querySelector('select[name="idDenP"]');
                    if (contenedorSelect && contenedorSelect.closest('.campo')) {
                        contenedorSelect.closest('.campo').style.display = 'none';
                    }
                }
                
                modal.showModal();
            }
        });
    });

    // 2. Cerrar cualquier modal usando el botón con clase .btn-cerrar o atributo data-cerrar
    document.querySelectorAll("[data-cerrar], .btn-cerrar-modal").forEach(btn => {
        btn.addEventListener("click", () => {
            const modal = btn.closest("dialog");
            if (modal) {
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
                cerrarModalAnimado(modal);
            }
        });
    });

    // 4. Apertura automática por servidor (para edición)
    const modalRegistro = document.getElementById("modalRegistro");
    if (modalRegistro && modalRegistro.hasAttribute("open")) {
        modalRegistro.removeAttribute("open");
        
        // Aseguramos que en modo edición SÍ se muestre el selector de doctor de preferencia
        const contenedorSelect = modalRegistro.querySelector('select[name="idDenP"]');
        if (contenedorSelect && contenedorSelect.closest('.campo')) {
            contenedorSelect.closest('.campo').style.display = 'block';
        }
        
        modalRegistro.showModal();
    }
});

// 5. Función global para disparar el modal de confirmación de eliminación
function abrirModalEliminar(id) {
    const modal = document.getElementById("modalEliminar");
    const btnConfirmar = document.getElementById("btnConfirmarEliminar");
    
    if (btnConfirmar) {
        btnConfirmar.href = "Control?accion=eliminar&id=" + id;
    }
    
    if (modal) {
        modal.showModal();
    }
}

// 6. Animación de salida fluida al cambiar de vista (ej. Volver)
document.addEventListener("click", function(e) {
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