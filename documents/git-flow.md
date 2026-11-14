# Git Flow

Comandos iniciales:

```
git clone https://github.com/Glooskovint/health-monitoring.git
cd health-monitoring
git checkout -b feature/backend-api
```

Cada integrante debe crear su propia rama.

## Reglas de trabajo

Estas son las reglas que todos deben respetar:

1. Nadie trabaja directamente sobre `main`.
2. Cada funcionalidad se desarrolla en una rama.
3. Cada cambio importante se sube mediante Pull Request.
4. El código debe ser revisado antes de fusionarse.
5. No se suben archivos temporales ni credenciales.
6. Todos deben sincronizar sus ramas con `main` regularmente.

## Estructura de commits

Todos deben escribir commits con una estructura consistente:

```
tipo(modulo): descripcion
```

Ejemplos:

```
feat(backend): create monitoring endpoint
feat(frontend): add health dashboard
feat(ml): implement prediction model
fix(backend): handle database disconnection
test(qa): add monitoring API tests
docs: update installation instructions
```

### Tipos recomendados:

| Tipo | Uso |
| -- | -- |
| feat | Nueva funcionalidad |
| fix | Corrección de errores |
| test | Pruebas |
| docs | Documentación |
| refactor | Mejorar código |
| chore | Configuración |