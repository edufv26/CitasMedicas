/* 
 * Archivo: menu.js
 * Descripción: Control de menús desplegables, accesibilidad y pantalla de carga (Loader).
 */

document.addEventListener("DOMContentLoaded", () => {

    // ==========================================
    // 1. PANTALLA DE CARGA (DURACIÓN DE 1 SEGUNDO)
    // ==========================================
    const loader = document.getElementById("loading-overlay");

    // Interceptar formularios para que se luzca el loader 1 segundo
    const forms = document.querySelectorAll("form");
    forms.forEach(form => {
        form.addEventListener("submit", (e) => {
            e.preventDefault(); // Frenamos el envío inmediato
            if (loader) {
                loader.classList.add("active");
            }
            
            // Esperamos 1 segundo exacto y mandamos el formulario
            setTimeout(() => {
                form.submit();
            }, 1000);
        });
    });

    // Interceptar enlaces del menú, acciones y el botón Volver con el retraso de 1s
    document.querySelectorAll(".dropdown-menu a, .nav-actions a, .btn-regresar").forEach(link => {
        link.addEventListener("click", (e) => {
            const href = link.getAttribute("href");
            if (href && href !== "#" && !href.startsWith("javascript")) {
                e.preventDefault(); // Frenamos el salto inmediato
                if (loader) {
                    loader.classList.add("active");
                }
                
                // Esperamos 1 segundo y redirigimos manualmente
                setTimeout(() => {
                    window.location.href = href;
                }, 1000);
            }
        });
    });

    // ==========================================
    // 2. LÓGICA DE MENÚS DESPLEGABLES
    // ==========================================
    const navItems = document.querySelectorAll(".nav-item");
    const toggles = document.querySelectorAll(".drop-toggle");

    function cerrarMenus(excepto = null) {
        navItems.forEach(item => {
            if (item !== excepto) {
                item.classList.remove("active");
                const button = item.querySelector(".drop-toggle");
                if (button) {
                    button.setAttribute("aria-expanded", "false");
                }
            }
        });
    }

    toggles.forEach(button => {
        button.addEventListener("click", (event) => {
            event.stopPropagation();
            const item = button.closest(".nav-item");
            const estabaAbierto = item.classList.contains("active");
            cerrarMenus();
            if (!estabaAbierto) {
                item.classList.add("active");
                button.setAttribute("aria-expanded", "true");
            }
        });
    });

    document.addEventListener("click", (event) => {
        if (!event.target.closest(".navbar-clinica")) {
            cerrarMenus();
        }
    });

    document.querySelectorAll(".dropdown-menu a").forEach(link => {
        link.addEventListener("click", () => {
            cerrarMenus();
        });
    });

    document.addEventListener("keydown", (event) => {
        if (event.key === "Escape") {
            const menuAbierto = document.querySelector(".nav-item.active");
            if (menuAbierto) {
                const button = menuAbierto.querySelector(".drop-toggle");
                cerrarMenus();
                if (button) {
                    button.focus();
                }
            }
        }
    });

});