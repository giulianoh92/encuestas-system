const form = document.getElementById('csvForm');
const fileInput = document.getElementById('csvFile');
const errorMsg = document.getElementById('errorMsg');

function showError(msg) {
    errorMsg.textContent = msg;
    errorMsg.style.display = 'block';
}

function hideError() {
    errorMsg.style.display = 'none';
}

form.addEventListener('submit', function (e) {
    hideError();
    const file = fileInput.files[0];

    if (!file) {
        showError('Debe seleccionar un archivo CSV.');
        e.preventDefault();
        return;
    }

    if (!file.name.endsWith('.csv')) {
        showError('El archivo debe tener extensión .csv');
        e.preventDefault();
        return;
    }

    const reader = new FileReader();

    reader.onload = function (evt) {
        const lines = evt.target.result.split(/\r?\n/).filter(l => l.trim().length > 0);

        if (!/^\d{8}$/.test(lines[0].trim())) {
            lines[0] = lines[0].slice(8).trim();
        }

        const finIndex = lines.findIndex(l => /^FIN\d{10}$/.test(l.trim()));
        if (finIndex === -1) {
            showError('No se encontró la línea FIN.');
            e.preventDefault();
            return;
        }

        const detailLines = lines.slice(1, finIndex);
        const expectedCount = parseInt(lines[finIndex].trim().slice(3), 10);

        if (detailLines.length !== expectedCount) {
            showError(`La cantidad de líneas de detalle (${detailLines.length}) no coincide con el valor informado (${expectedCount}).`);
            e.preventDefault();
            return;
        }

        for (let i = 0; i < detailLines.length; i++) {
            const line = detailLines[i].trim();
            const parts = line.split(',');
            if (parts.length !== 6) {
                showError(`Línea ${i + 2} debe tener 6 campos separados por comas.`);
                e.preventDefault();
                return;
            }
            const regexes = [/^\d+$/, /^\d+$/, /^\d+$/, /^\d{8}$/, /^\d+$/, /^\d+$/];
            for (let j = 0; j < 6; j++) {
                if (!regexes[j].test(parts[j])) {
                    showError(`Línea ${i + 2} no cumple el formato esperado (ver ejemplo).`);
                    e.preventDefault();
                    return;
                }
            }
        }

        const blob = new Blob([detailLines.join('\n')], { type: 'text/csv' });
        const formData = new FormData();
        formData.append('file', blob, file.name);

        fetch('/cargar_csv/', {
            method: 'POST',
            body: formData
        })
            .then(async response => {
                if (response.ok) {
                    alert('CSV cargado y procesado correctamente');
                    window.location.reload();
                } else {
                    const data = await response.json();
                    showError(data.detail || 'Error al procesar el archivo');
                }
            })
            .catch(() => {
                showError('Error de red al enviar el archivo');
            });

        e.preventDefault();
    };

    reader.onerror = function () {
        showError('No se pudo leer el archivo.');
        e.preventDefault();
    };

    reader.readAsText(file);
    e.preventDefault();
});
