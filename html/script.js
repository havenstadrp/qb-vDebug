const topSpeed = document.getElementById('data-top');
const speed1 = document.getElementById('data-speed-1');
const speed2 = document.getElementById('data-speed-2');
const speed3 = document.getElementById('data-speed-3');
const speed4 = document.getElementById('data-speed-4');

const updateTime = async (vehData) => {
    let current = Number(vehData.mph)
    let step1 = Number(vehData.step1)
    let step2 = Number(vehData.step2)
    let step3 = Number(vehData.step3)
    let step4 = Number(vehData.step4)
    
    if (current >= step1) {
        speed1.style.color = 'rgba(245, 217, 39, 240)';
    };
    if (current >= step2) {
        speed2.style.color = 'rgba(245, 217, 39, 240)';
    };
    if (current >= step3) {
        speed3.style.color = 'rgba(245, 217, 39, 240)';
    };
    if (current >= step4) {
        speed4.style.color = 'rgba(245, 217, 39, 240)';
    };

    $("#data-accel").html('Time Accel: ' + vehData.accel);
    $("#data-brake").html('Time Brake: ' + vehData.brake);
    $("#data-speed-1").html(vehData.step1 + vehData.units + ': ' + vehData.speed1);
    $("#data-speed-2").html(vehData.step2 + vehData.units + ': ' + vehData.speed2);
    $("#data-speed-3").html(vehData.step3 + vehData.units + ': ' + vehData.speed3);
    $("#data-speed-4").html(vehData.step4 + vehData.units + ': ' + vehData.speed4);
};

const updateData = async (vehData) => {
    let top = Number(vehData.topSpeed);
    let current = Number(vehData.mph);

    if (top > current) {
        topSpeed.style.color = 'rgba(245, 217, 39, 255)';
    } else if (top < current) {
        topSpeed.style.color = 'rgba(0, 152, 255, 255)';
    };

    $("#data-model").html('Model: ' + vehData.model);
    $("#data-engine").html('Engine: ' + vehData.engine);
    $("#data-body").html('Body: ' + vehData.body);
    $("#data-tank").html('Tank: ' + vehData.tank);
    $("#data-gear").html('Gear: ' + vehData.gear);
    $("#data-rpm").html('RPM: ' + vehData.rpm);
    $("#data-mph").html('Speed: ' + vehData.mph);
    $("#data-top").html('Top Speed: ' + vehData.topSpeed);
};

const resetData = async () => {
    topSpeed.style.color = 'rgba(55, 215, 55, 240)';
    speed1.style.color = 'rgba(210, 210, 210, 240)';
    speed2.style.color = 'rgba(210, 210, 210, 240)';
    speed3.style.color = 'rgba(210, 210, 210, 240)';
    speed4.style.color = 'rgba(210, 210, 210, 240)';
};

const showUI = async () => {
    $(".container").fadeIn(300);
};

const hideUI = async () => {
    $(".container").hide();
};

window.addEventListener("message", (event) => {
    const data = event.data;
    const action = data.action;
    const vehData = data.data;
    switch (action) {
        case "UPDATE_TIME":
            return updateTime(vehData);
        case "UPDATE_DATA":
            return updateData(vehData);
        case "RESET_DATA":
            return resetData();
        case "SHOW_UI":
            return showUI();
        case "HIDE_UI":
            return hideUI();
        default:
            return;
    }
});
