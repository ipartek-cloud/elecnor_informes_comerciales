
// --- Funciones UI Globales ---
export const GlobalUI = {
    // Muestra u oculta el Loading Overlay (bloqueo oscuro con spinner)
    showLoading: function (message = "Procesando petición...") {
        document.querySelector('#loadingOverlay .loading-text').textContent = message;
        document.getElementById('loadingOverlay').classList.remove('d-none');
    },
    // Oculta el Loading Overlay
    hideLoading: function () {
        document.getElementById('loadingOverlay').classList.add('d-none');
    },

    // Notificación tipo Toast no bloqueante con SweetAlert2
    // tipo: 'success', 'danger', 'warning', 'info'
    showAlert: function (mensaje, tipo = "info", titulo = "") {
        const iconMap = { success: 'success', danger: 'error', warning: 'warning', info: 'info' };
        Swal.fire({
            toast: true,
            position: 'top-end',
            icon: iconMap[tipo] || 'info',
            title: titulo || mensaje,
            text: titulo ? mensaje : undefined,
            width: '400px',
            showConfirmButton: false,
            timer: tipo !== 'danger' ? 5000 : undefined,
            timerProgressBar: tipo !== 'danger',
            showClass: { popup: '' }, // Quitar animación de entrada (evita balanceo)
            hideClass: { popup: '' }, // Quitar animación de salida
            didOpen: (toast) => {
                toast.addEventListener('mouseenter', Swal.stopTimer);
                toast.addEventListener('mouseleave', Swal.resumeTimer);
            }
        });
    },

    // Diálogo de confirmación bloqueante con SweetAlert2. Devuelve Promise<boolean>.
    showConfirm: async function (mensaje, titulo = "¿Está seguro?") {
        const result = await Swal.fire({
            title: titulo,
            text: mensaje,
            icon: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#00468B', // Azul Elecnor
            cancelButtonColor: '#6c757d',
            confirmButtonText: 'Sí, continuar',
            cancelButtonText: 'Cancelar',
            reverseButtons: true,
            showClass: { popup: '' }, // Quitar animación de entrada
            hideClass: { popup: '' }  // Quitar animación de salida
        });
        return result.isConfirmed;
    }
};

// --- Utils API HTTP Fetch Wrapper ---
export const ApiClient = {
    post: async function (url, bodyObj, requiresAuth = false) {
        let headers = { 'Content-Type': 'application/json' };

        if (requiresAuth) {
            const token = sessionStorage.getItem('jwt_token');
            if (token) headers['Authorization'] = `Bearer ${token}`;
        }

        const response = await fetch(url, {
            method: 'POST',
            headers: headers,
            body: JSON.stringify(bodyObj)
        });

        if (response.status === 403) {
            const errorData = await response.json().catch(() => ({}));
            GlobalUI.showAlert(errorData.message || "Acceso restringido. Su puesto de trabajo no cuenta con privilegios para consultar este informe.", "danger");
            throw new Error("ACCESO_RESTRINGIDO");
        }

        return response;
    },

    get: async function (url, requiresAuth = true) {
        let headers = { 'Accept': 'application/json' };
        if (requiresAuth) {
            const token = sessionStorage.getItem('jwt_token');
            if (token) headers['Authorization'] = `Bearer ${token}`;
        }

        const response = await fetch(url, { method: 'GET', headers: headers });

        if (response.status === 403) {
            const errorData = await response.json().catch(() => ({}));
            GlobalUI.showAlert(errorData.message || "Acceso restringido. Su puesto de trabajo no cuenta con privilegios para consultar este informe.", "danger");
            throw new Error("ACCESO_RESTRINGIDO");
        }

        return response;
    }
}

// --- Utilidad JWT ---
// Decodifica el payload del token JWT (Base64url) sin librerias externas.
export function decodeJwt(token) {
    try {
        const base64 = token.split('.')[1].replace(/-/g, '+').replace(/_/g, '/');
        const binString = atob(base64);
        const bytes = Uint8Array.from(binString, m => m.codePointAt(0));
        return JSON.parse(new TextDecoder().decode(bytes));
    } catch {
        return null;
    }
}
