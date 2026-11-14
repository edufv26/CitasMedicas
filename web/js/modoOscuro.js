/* 
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/JavaScript.js to edit this template
 */

/* 
 * Script de Modo Oscuro - Clínica Dental (Protegido contra ejecución doble)
 */
if (window.modoOscuroLoaded) {
    console.warn("⚠️ modoOscuro.js ya estaba cargado. Evitando ejecución duplicada.");
} else {
    window.modoOscuroLoaded = true;

    document.addEventListener("DOMContentLoaded", () => {
        const body = document.body;
        const btnModo = document.getElementById("btn-modo-oscuro");

        const iconSpan = btnModo ? btnModo.querySelector("span.fa") : null;

        // Función para actualizar el icono según el modo
        function actualizarIcono(isDark) {
            if (!iconSpan) return;
            if (isDark) {
                iconSpan.className = "fa fa-sun-o"; // Sol para volver al modo claro
            } else {
                iconSpan.className = "fa fa-moon-o"; // Luna para modo oscuro
            }
        }

        // 1. Al cargar la página, revisamos la preferencia guardada
        const darkModeGuardado = localStorage.getItem("darkMode") === "true";
        if (darkModeGuardado) {
            body.classList.add("dark-mode");
        }
        actualizarIcono(darkModeGuardado);

        // 2. Evento de clic en el botón (asegurando que no se duplique el evento)
        if (btnModo) {
            // Evitamos duplicar listeners por si acaso
            if (!btnModo.dataset.listenerAttached) {
                btnModo.dataset.listenerAttached = "true";
                
                btnModo.addEventListener("click", (e) => {
                    e.preventDefault();
                    
                    body.classList.toggle("dark-mode");
                    const isDark = body.classList.contains("dark-mode");
                    
                    actualizarIcono(isDark);
                    localStorage.setItem("darkMode", isDark);
                });
            }
        } else {
            console.warn("⚠️ Ojo: No se encontró el botón con id='btn-modo-oscuro' en esta vista.");
        }
    });
}