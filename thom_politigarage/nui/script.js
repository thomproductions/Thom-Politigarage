const state = {
    visible: false,
    garage: null,
    categories: [],
    vehicles: [],
    activeVehicles: [],
    unitCategories: [],
    activeCategoryId: "active",
    filteredVehicles: [],
    selectedVehicle: null
};

const overlay = document.getElementById("overlay");
const vehiclesGrid = document.getElementById("vehicles-grid");
const sidebarNav = document.getElementById("sidebar-nav");
const toolbarTitle = document.getElementById("toolbar-title");
const toolbarMeta = document.getElementById("toolbar-meta");
const garageLabelEl = document.getElementById("garage-label");
const searchInput = document.getElementById("search-input");
const closeButton = document.getElementById("close-button");
const headerClock = document.getElementById("header-clock");
const themeToggle = document.getElementById("theme-toggle");
const modalBackdrop = document.getElementById("spawn-modal-backdrop");
const modalVehicleName = document.getElementById("modal-vehicle-name");
const modalCancel = document.getElementById("modal-cancel");
const modalConfirm = document.getElementById("modal-confirm");
const unitCategorySelect = document.getElementById("unit-category");
const unitCategoryDisplay = document.getElementById("unit-category-display");
const unitCategoryOptions = document.getElementById("unit-category-options");
const unitCategoryDisplayLabel = unitCategoryDisplay
    ? unitCategoryDisplay.querySelector(".select-display-label")
    : null;
const unitNumberInput = document.getElementById("unit-number");

const isFiveM = typeof GetParentResourceName === "function" || typeof window.invokeNative === "function";
const defaultStats = [
    { label: "Fart", value: 80 },
    { label: "Acceleration", value: 75 },
    { label: "Håndtering", value: 75 }
];
const vehicleStatMap = {
    stratos_marked: [
        { label: "Fart", value: 91 },
        { label: "Acceleration", value: 86 },
        { label: "Håndtering", value: 83 }
    ],
    gxb_marked: [
        { label: "Fart", value: 85 },
        { label: "Acceleration", value: 79 },
        { label: "Håndtering", value: 75 }
    ],
    polaris_marked: [
        { label: "Fart", value: 87 },
        { label: "Acceleration", value: 82 },
        { label: "Håndtering", value: 80 }
    ],
    bike1: [
        { label: "Topfart", value: 90 },
        { label: "Acceleration", value: 92 },
        { label: "Håndtering", value: 86 }
    ],
    stratos_civil: [
        { label: "Fart", value: 89 },
        { label: "Acceleration", value: 84 },
        { label: "Håndtering", value: 82 }
    ],
    polaris_civil: [
        { label: "Fart", value: 85 },
        { label: "Acceleration", value: 80 },
        { label: "Håndtering", value: 78 }
    ],
    gxb_civil: [
        { label: "Fart", value: 83 },
        { label: "Acceleration", value: 78 },
        { label: "Håndtering", value: 74 }
    ],
    unmarked: [
        { label: "Fart", value: 88 },
        { label: "Acceleration", value: 85 },
        { label: "Håndtering", value: 81 }
    ],
    iq4: [
        { label: "Fart", value: 84 },
        { label: "Acceleration", value: 91 },
        { label: "Håndtering", value: 79 }
    ],
    argento_marked: [
        { label: "Fart", value: 90 },
        { label: "Acceleration", value: 87 },
        { label: "Håndtering", value: 82 }
    ],
    rhinehart_marked: [
        { label: "Fart", value: 82 },
        { label: "Acceleration", value: 75 },
        { label: "Håndtering", value: 77 }
    ],
    rebla_marked: [
        { label: "Fart", value: 81 },
        { label: "Acceleration", value: 74 },
        { label: "Håndtering", value: 76 }
    ],
    buffalo_marked: [
        { label: "Fart", value: 92 },
        { label: "Acceleration", value: 90 },
        { label: "Håndtering", value: 84 }
    ],
    xls_marked: [
        { label: "Fart", value: 79 },
        { label: "Acceleration", value: 72 },
        { label: "Håndtering", value: 74 }
    ],
    iwagen_marked: [
        { label: "Fart", value: 80 },
        { label: "Acceleration", value: 88 },
        { label: "Håndtering", value: 78 }
    ],
    caracara_marked: [
        { label: "Fart", value: 78 },
        { label: "Acceleration", value: 73 },
        { label: "Håndtering", value: 76 }
    ],
    bf400_marked: [
        { label: "Topfart", value: 89 },
        { label: "Acceleration", value: 91 },
        { label: "Håndtering", value: 87 }
    ],
    naga1300: [
        { label: "Topfart", value: 94 },
        { label: "Acceleration", value: 95 },
        { label: "Håndtering", value: 82 }
    ],
    shinobi: [
        { label: "Topfart", value: 96 },
        { label: "Acceleration", value: 97 },
        { label: "Håndtering", value: 86 }
    ],
    indsatsleder: [
        { label: "Beskyttelse", value: 92 },
        { label: "Kapacitet", value: 86 },
        { label: "Fart", value: 72 }
    ],
    indsatsleder_v2: [
        { label: "Beskyttelse", value: 94 },
        { label: "Kapacitet", value: 88 },
        { label: "Fart", value: 74 }
    ],
    gruppevogn: [
        { label: "Kapacitet", value: 96 },
        { label: "Beskyttelse", value: 85 },
        { label: "Fart", value: 64 }
    ],
    transfer: [
        { label: "Kapacitet", value: 90 },
        { label: "Komfort", value: 82 },
        { label: "Fart", value: 70 }
    ],
    brute: [
        { label: "Beskyttelse", value: 97 },
        { label: "Kapacitet", value: 94 },
        { label: "Fart", value: 57 }
    ],
    swat: [
        { label: "Beskyttelse", value: 99 },
        { label: "Kapacitet", value: 96 },
        { label: "Fart", value: 60 }
    ]
};

function getResourceName() {
    if (typeof GetParentResourceName === "function") {
        return GetParentResourceName();
    }
    return "tpgarage";
}

const resourceName = getResourceName();

function applyTheme(theme) {
    const value = theme === "light" ? "light" : "dark";
    document.body.dataset.theme = value;
    try {
        localStorage.setItem("tpgarage-theme", value);
    } catch (e) {}
}

function setVisible(visible) {
    state.visible = visible;
    if (visible) {
        overlay.classList.remove("hidden");
        requestAnimationFrame(() => {
            overlay.classList.add("visible");
        });
    } else {
        overlay.classList.remove("visible");
        setTimeout(() => {
            if (!state.visible) {
                overlay.classList.add("hidden");
            }
        }, 220);
    }
}

function openModal(vehicle) {
    state.selectedVehicle = vehicle;
    modalVehicleName.textContent = vehicle.displayName || "";
    unitNumberInput.value = "1";
    if (!modalBackdrop.classList.contains("visible")) {
        modalBackdrop.classList.remove("hidden");
        requestAnimationFrame(() => {
            modalBackdrop.classList.add("visible");
        });
    }
}

function closeModal() {
    modalBackdrop.classList.remove("visible");
    setTimeout(() => {
        if (!modalBackdrop.classList.contains("visible")) {
            modalBackdrop.classList.add("hidden");
        }
    }, 200);
}

function updateClock() {
    const now = new Date();
    const h = String(now.getHours()).padStart(2, "0");
    const m = String(now.getMinutes()).padStart(2, "0");
    const s = String(now.getSeconds()).padStart(2, "0");
    headerClock.textContent = h + ":" + m + ":" + s;
}

setInterval(updateClock, 1000);
updateClock();

function renderSidebar() {
    sidebarNav.innerHTML = "";
    state.categories.forEach((category) => {
        const item = document.createElement("button");
        item.type = "button";
        item.className = "sidebar-item" + (category.id === state.activeCategoryId ? " active" : "");
        item.dataset.categoryId = category.id;
        const inner = document.createElement("div");
        inner.className = "sidebar-item-content";
        const icon = document.createElement("div");
        icon.className = "sidebar-icon";
        const svg = document.createElementNS("http://www.w3.org/2000/svg", "svg");
        svg.setAttribute("class", "sidebar-icon-svg");
        svg.setAttribute("viewBox", "0 0 24 24");
        const use = document.createElementNS("http://www.w3.org/2000/svg", "use");
        use.setAttribute("href", "#icon-cat-" + category.id);
        svg.appendChild(use);
        icon.appendChild(svg);
        const label = document.createElement("div");
        label.className = "sidebar-label";
        label.textContent = category.label;
        inner.appendChild(icon);
        inner.appendChild(label);
        item.appendChild(inner);
        item.addEventListener("click", () => {
            setActiveCategory(category.id);
        });
        sidebarNav.appendChild(item);
    });
}

function setActiveCategory(categoryId) {
    state.activeCategoryId = categoryId;
    const items = sidebarNav.querySelectorAll(".sidebar-item");
    items.forEach((item) => {
        if (item.dataset.categoryId === categoryId) {
            item.classList.add("active");
        } else {
            item.classList.remove("active");
        }
    });
    const category = state.categories.find((c) => c.id === categoryId);
    toolbarTitle.textContent = category ? category.label : "";
    applyFilters();
}

function applyFilters() {
    const q = (searchInput.value || "").trim().toLowerCase();
    const categoryId = state.activeCategoryId;
    const source =
        categoryId === "active"
            ? state.activeVehicles
            : state.vehicles;
    state.filteredVehicles = source.filter((v) => {
        if (categoryId !== "active" && v.categoryId !== categoryId) {
            return false;
        }
        if (!q) {
            return true;
        }
        const haystack =
            (v.displayName || "") +
            " " +
            (v.classLabel || "") +
            " " +
            (v.garage || "") +
            " " +
            (v.categoryId || "");
        return haystack.toLowerCase().includes(q);
    });
    renderVehicles();
}

function renderVehicles() {
    vehiclesGrid.innerHTML = "";
    toolbarMeta.textContent = state.filteredVehicles.length + " køretøjer";
    const isActiveView = state.activeCategoryId === "active";
    state.filteredVehicles.forEach((vehicle) => {
        const card = document.createElement("article");
        card.className = "vehicle-card";
        const media = document.createElement("div");
        media.className = "vehicle-media";
        const img = document.createElement("img");
        img.className = "vehicle-image";
        if (vehicle.image) {
            img.src = "images/" + vehicle.image;
        } else {
            img.src = "https://via.placeholder.com/400x220/020617/0ea5e9?text=POLITI+GARAGE";
        }
        img.alt = vehicle.displayName || vehicle.model || "Køretøj";
        const overlayEl = document.createElement("div");
        overlayEl.className = "vehicle-media-overlay";
        const badgeRow = document.createElement("div");
        badgeRow.className = "vehicle-badge-row";
        const primaryBadge = document.createElement("div");
        primaryBadge.className = "vehicle-badge vehicle-badge-primary";
        primaryBadge.textContent = vehicle.classLabel || "POLITI";
        const secondaryBadge = document.createElement("div");
        secondaryBadge.className = "vehicle-badge vehicle-badge-secondary";
        secondaryBadge.textContent = vehicle.categoryId || "";
        if (vehicle.categoryId) {
            secondaryBadge.classList.add("badge-cat-" + vehicle.categoryId);
        }
        badgeRow.appendChild(primaryBadge);
        badgeRow.appendChild(secondaryBadge);
        media.appendChild(img);
        media.appendChild(overlayEl);
        media.appendChild(badgeRow);
        const body = document.createElement("div");
        body.className = "vehicle-body";
        const titleRow = document.createElement("div");
        titleRow.className = "vehicle-title-row";
        const name = document.createElement("div");
        name.className = "vehicle-name";
        name.textContent = vehicle.displayName || vehicle.model || "";
        titleRow.appendChild(name);
        body.appendChild(titleRow);

        if (isActiveView) {
            const drivers = Array.isArray(vehicle.drivers) ? vehicle.drivers : [];
            const driverText = drivers.length ? drivers.join(" & ") : "Ukendt";
            const driverLine = document.createElement("div");
            driverLine.className = "vehicle-garage";
            driverLine.textContent = "Koblet på: " + driverText;
            body.appendChild(driverLine);

            const fromConfig = state.vehicles.find((v) => v.model === vehicle.model);
            const modelPretty =
                vehicle.modelLabel ||
                (fromConfig ? fromConfig.displayName : "") ||
                vehicle.garage ||
                vehicle.model ||
                "";
            const modelLine = document.createElement("div");
            modelLine.className = "vehicle-garage";
            modelLine.textContent = "Model: " + modelPretty;
            body.appendChild(modelLine);
        } else {
            const stats = document.createElement("div");
            stats.className = "vehicle-stats";
            const statConfig = vehicleStatMap[vehicle.model] || defaultStats;
            statConfig.forEach((stat) => {
                const row = document.createElement("div");
                row.className = "vehicle-stat-row";
                const labelEl = document.createElement("div");
                labelEl.className = "vehicle-stat-label";
                labelEl.textContent = stat.label;
                const bar = document.createElement("div");
                bar.className = "vehicle-stat-bar";
                const fill = document.createElement("div");
                fill.className = "vehicle-stat-bar-fill";
                fill.style.setProperty("--value", String(stat.value));
                bar.appendChild(fill);
                row.appendChild(labelEl);
                row.appendChild(bar);
                stats.appendChild(row);
            });
            body.appendChild(stats);
        }
        const footer = document.createElement("div");
        footer.className = "vehicle-footer";
        const btn = document.createElement("button");
        btn.type = "button";
        btn.className = "btn btn-primary";
        btn.textContent = isActiveView ? "KOBLE PÅ" : "SPAWN KØRETØJ";
        btn.addEventListener("click", () => {
            if (isActiveView) {
                postNui("connectUnit", { unitId: vehicle.unitId });
                return;
            }
            openModal(vehicle);
        });
        footer.appendChild(btn);
        card.appendChild(media);
        card.appendChild(body);
        card.appendChild(footer);
        vehiclesGrid.appendChild(card);
    });
}

function renderUnitCategories() {
    unitCategorySelect.innerHTML = "";
    if (unitCategoryOptions) {
        unitCategoryOptions.innerHTML = "";
    }
    if (!state.unitCategories.length) return;
    state.unitCategories.forEach((cat, index) => {
        const opt = document.createElement("option");
        opt.value = cat.id;
        opt.textContent = cat.label;
        unitCategorySelect.appendChild(opt);

        if (unitCategoryOptions) {
            const item = document.createElement("button");
            item.type = "button";
            item.className = "select-option-item" + (index === 0 ? " active" : "");
            item.dataset.value = cat.id;
            item.textContent = cat.label;
            item.addEventListener("click", () => {
                unitCategorySelect.value = cat.id;
                if (unitCategoryDisplayLabel) {
                    unitCategoryDisplayLabel.textContent = cat.label;
                }
                const all = unitCategoryOptions.querySelectorAll(".select-option-item");
                all.forEach((el) => el.classList.toggle("active", el === item));
                unitCategoryOptions.classList.remove("open");
            });
            unitCategoryOptions.appendChild(item);
        }
    });
    const first = state.unitCategories[0];
    unitCategorySelect.value = first.id;
    if (unitCategoryDisplayLabel) {
        unitCategoryDisplayLabel.textContent = first.label;
    }
}

function handleOpen(data) {
    state.garage = data.garage || null;
    state.categories = Array.isArray(data.categories) ? data.categories : [];
    state.vehicles = Array.isArray(data.vehicles) ? data.vehicles : [];
    state.activeVehicles = Array.isArray(data.activeVehicles) ? data.activeVehicles : [];
    state.unitCategories = Array.isArray(data.unitCategories) ? data.unitCategories : [];
    garageLabelEl.textContent = state.garage && state.garage.label ? state.garage.label : "Politi Garage";
    renderSidebar();
    renderUnitCategories();
    const defaultCategory = state.categories[0];
    state.activeCategoryId = defaultCategory ? defaultCategory.id : "active";
    if (defaultCategory) {
        toolbarTitle.textContent = defaultCategory.label;
    }
    searchInput.value = "";
    applyFilters();
    const statusPill = document.querySelector(".header-status-pill");
    if (statusPill) {
        statusPill.classList.remove("status-pulse");
        void statusPill.offsetWidth;
        statusPill.classList.add("status-pulse");
    }
    setVisible(true);
}

function handleClose() {
    setVisible(false);
}

window.addEventListener("message", (event) => {
    const data = event.data || {};
    if (data.action === "open") {
        handleOpen(data);
    } else if (data.action === "close") {
        handleClose();
    } else if (data.action === "updateActiveVehicles") {
        state.activeVehicles = Array.isArray(data.activeVehicles) ? data.activeVehicles : [];
        if (state.activeCategoryId === "active") {
            applyFilters();
        }
    }
});

function postNui(event, payload) {
    if (!isFiveM) {
        return;
    }
    fetch("https://" + resourceName + "/" + event, {
        method: "POST",
        headers: {
            "Content-Type": "application/json; charset=UTF-8"
        },
        body: JSON.stringify(payload || {})
    }).catch(() => {});
}

function requestClose() {
    postNui("close", {});
}

closeButton.addEventListener("click", () => {
    requestClose();
});

modalCancel.addEventListener("click", () => {
    closeModal();
});

modalConfirm.addEventListener("click", () => {
    if (!state.selectedVehicle) return;
    const unitCategory = unitCategorySelect.value || "Bravo";
    const unitNumber = parseInt(unitNumberInput.value, 10);
    const payload = {
        model: state.selectedVehicle.model,
        withGps: true,
        unitCategory: unitCategory,
        unitNumber: isNaN(unitNumber) ? 1 : unitNumber
    };
    postNui("spawnVehicle", payload);
    closeModal();
});

unitNumberInput.addEventListener("input", () => {
    let value = parseInt(unitNumberInput.value, 10);
    if (isNaN(value)) return;
    if (value > 99) value = 99;
    if (value < 1) value = 1;
    unitNumberInput.value = String(value);
});

if (unitCategoryDisplay && unitCategoryOptions) {
    unitCategoryDisplay.addEventListener("click", () => {
        const isOpen = unitCategoryOptions.classList.contains("open");
        unitCategoryOptions.classList.toggle("open", !isOpen);
    });

    document.addEventListener("click", (e) => {
        if (!unitCategoryDisplay.contains(e.target) && !unitCategoryOptions.contains(e.target)) {
            unitCategoryOptions.classList.remove("open");
        }
    });
}

window.addEventListener("keydown", (e) => {
    if (e.key === "Escape") {
        if (modalBackdrop.classList.contains("visible")) {
            closeModal();
        } else if (state.visible) {
            requestClose();
        }
    }
});

searchInput.addEventListener("input", () => {
    applyFilters();
});

window.addEventListener("load", () => {
    overlay.classList.add("hidden");
    modalBackdrop.classList.add("hidden");
    try {
        const savedTheme = localStorage.getItem("tpgarage-theme");
        applyTheme(savedTheme === "light" ? "light" : "dark");
    } catch (e) {
        applyTheme("dark");
    }
    if (themeToggle) {
        themeToggle.addEventListener("click", () => {
            const nextTheme = document.body.dataset.theme === "light" ? "dark" : "light";
            applyTheme(nextTheme);
        });
    }
    if (!isFiveM) {
        const mockData = {
            garage: {
                id: "browser_test",
                label: "© Thom Productions"
            },
            categories: [
                { id: "active", label: "Aktive Enheder" },
                { id: "marked", label: "Markerede" },
                { id: "mc", label: "MC" },
                { id: "civil", label: "Civil" },
                { id: "special", label: "Special enhed" }
            ],
            vehicles: [
                {
                    model: "stratos_marked",
                    displayName: "Markeret Stratos",
                    garage: "Politi",
                    categoryId: "marked",
                    classLabel: "POLITI",
                    fuel: 100,
                    engine: 1000,
                    body: 1000,
                    image: "stratos.png"
                },
                {
                    model: "gxb_marked",
                    displayName: "Markeret GXB",
                    garage: "Politi",
                    categoryId: "marked",
                    classLabel: "POLITI",
                    fuel: 100,
                    engine: 1000,
                    body: 1000,
                    image: "gxb.png"
                },
                {
                    model: "polaris_marked",
                    displayName: "Markeret Polaris",
                    garage: "Politi",
                    categoryId: "marked",
                    classLabel: "POLITI",
                    fuel: 100,
                    engine: 1000,
                    body: 1000,
                    image: "polaris.png"
                },
                {
                    model: "iq4",
                    displayName: "Markeret IQ4",
                    garage: "Politi",
                    categoryId: "marked",
                    classLabel: "POLITI",
                    fuel: 100,
                    engine: 1000,
                    body: 1000,
                    image: "id4.png"
                },
                {
                    model: "transfer",
                    displayName: "Transfer",
                    garage: "Politi",
                    categoryId: "special",
                    classLabel: "POLITI",
                    fuel: 100,
                    engine: 1000,
                    body: 1000,
                    image: "transfer.png"
                },
                {
                    model: "gruppevogn",
                    displayName: "Gruppevogn",
                    garage: "Politi",
                    categoryId: "special",
                    classLabel: "POLITI",
                    fuel: 100,
                    engine: 1000,
                    body: 1000,
                    image: "transferc.png"
                },
                {
                    model: "indsatsleder",
                    displayName: "Indsatsleder",
                    garage: "Politi",
                    categoryId: "special",
                    classLabel: "POLITI",
                    fuel: 100,
                    engine: 1000,
                    body: 1000,
                    image: "streiter.png"
                },
                {
                    model: "indsatsleder_v2",
                    displayName: "Indsatsleder V2",
                    garage: "Politi",
                    categoryId: "special",
                    classLabel: "POLITI",
                    fuel: 100,
                    engine: 1000,
                    body: 1000,
                    image: "indsatslederv2.png"
                },
                {
                    model: "brute",
                    displayName: "Brute",
                    garage: "Politi",
                    categoryId: "special",
                    classLabel: "POLITI",
                    fuel: 100,
                    engine: 1000,
                    body: 1000,
                    image: "brute.png"
                },
                {
                    model: "swat",
                    displayName: "Special-enhed",
                    garage: "Politi",
                    categoryId: "special",
                    classLabel: "POLITI",
                    fuel: 100,
                    engine: 1000,
                    body: 1000,
                    image: "brutec.png"
                },
                {
                    model: "stratos_civil",
                    displayName: "Stratos Civil",
                    garage: "Politi",
                    categoryId: "civil",
                    classLabel: "POLITI",
                    fuel: 100,
                    engine: 1000,
                    body: 1000,
                    image: "stratosc.png"
                },
                {
                    model: "polaris_civil",
                    displayName: "Polaris Civil",
                    garage: "Politi",
                    categoryId: "civil",
                    classLabel: "POLITI",
                    fuel: 100,
                    engine: 1000,
                    body: 1000,
                    image: "polarisc.png"
                },
                {
                    model: "gxb_civil",
                    displayName: "GXB Civil",
                    garage: "Politi",
                    categoryId: "civil",
                    classLabel: "POLITI",
                    fuel: 100,
                    engine: 1000,
                    body: 1000,
                    image: "gxbc.png"
                },
                {
                    model: "unmarked",
                    displayName: "Civil Enhed",
                    garage: "Politi",
                    categoryId: "civil",
                    classLabel: "POLITI",
                    fuel: 100,
                    engine: 1000,
                    body: 1000,
                    image: "glb.png"
                },
                {
                    model: "naga1300",
                    displayName: "Naga 1300",
                    garage: "Politi",
                    categoryId: "mc",
                    classLabel: "POLITI",
                    fuel: 100,
                    engine: 1000,
                    body: 1000,
                    image: "naga1300.png"
                },
                {
                    model: "shinobi",
                    displayName: "Shinobi",
                    garage: "Politi",
                    categoryId: "mc",
                    classLabel: "POLITI",
                    fuel: 100,
                    engine: 1000,
                    body: 1000,
                    image: "shinobi.png"
                },
                {
                    model: "argento_marked",
                    displayName: "Markeret Argento",
                    garage: "Politi",
                    categoryId: "marked",
                    classLabel: "POLITI",
                    fuel: 100,
                    engine: 1000,
                    body: 1000,
                    image: "argento.png"
                },
                {
                    model: "rhinehart_marked_2",
                    displayName: "Markeret Rhinehart",
                    garage: "Politi",
                    categoryId: "marked",
                    classLabel: "POLITI",
                    fuel: 100,
                    engine: 1000,
                    body: 1000,
                    image: "rhinehart.png"
                },
                {
                    model: "rebla_marked",
                    displayName: "Markeret Rebla",
                    garage: "Politi",
                    categoryId: "marked",
                    classLabel: "POLITI",
                    fuel: 100,
                    engine: 1000,
                    body: 1000,
                    image: "glb.png"
                },
                {
                    model: "buffalo_marked",
                    displayName: "Markeret Buffalo",
                    garage: "Politi",
                    categoryId: "marked",
                    classLabel: "POLITI",
                    fuel: 100,
                    engine: 1000,
                    body: 1000,
                    image: "buffalo.png"
                },
                {
                    model: "xls_marked",
                    displayName: "Markeret XLS",
                    garage: "Politi",
                    categoryId: "marked",
                    classLabel: "POLITI",
                    fuel: 100,
                    engine: 1000,
                    body: 1000,
                    image: "xls.png"
                },
                {
                    model: "iwagen_marked",
                    displayName: "Markeret I-Wagen",
                    garage: "Politi",
                    categoryId: "marked",
                    classLabel: "POLITI",
                    fuel: 100,
                    engine: 1000,
                    body: 1000,
                    image: "iwagen.png"
                },
                {
                    model: "caracara_marked",
                    displayName: "Markeret Caracara",
                    garage: "Politi",
                    categoryId: "marked",
                    classLabel: "POLITI",
                    fuel: 100,
                    engine: 1000,
                    body: 1000,
                    image: "caracara.png"
                },
                {
                    model: "bf400_marked",
                    displayName: "Markeret BF400",
                    garage: "Politi",
                    categoryId: "marked",
                    classLabel: "POLITI",
                    fuel: 100,
                    engine: 1000,
                    body: 1000,
                    image: "bf400.png"
                }
            ],
            unitCategories: [
                { id: "Bravo", label: "Bravo" },
                { id: "Mike", label: "Mike" },
                { id: "Mike Kilo", label: "Mike Kilo" },
                { id: "Kilo", label: "Kilo" },
                { id: "Lima", label: "Lima" },
                { id: "Træning", label: "Træning" }
            ]
        };
        handleOpen(mockData);
        return;
    }
});

