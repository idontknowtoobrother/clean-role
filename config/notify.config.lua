Notify = {}


Notify.dontHaveItem = function()
    
    -- แจ้งเตือนไม่มีไอเทมอาบน้ำ

    pcall(function()
        exports.nc_notify:PushNotification(playerId, {
            scale = 1.0,  -- ปรับขนาดของ Notify
            title = 'ต้องการไอเทมในการอาบน้ำ',  -- หัวเรื่อง
            description = 'ต้องการ สบู่',  -- รายละเอียด หากต้องการให้แสดงปุ่มกดให้ใช้ tag <btn></btn>
            type = 'warning',  -- ชนิดของ Notify * หากไม่ใส่จะเป็น 'info'
            position = 'top',  -- ตำแหน่งการแสดง ('top': บน | 'bottom': ล่าง) * หากไม่ใส่จะเป็น 'top'
            direction = 'right',  -- ตำแหน่งการแสดง ('left': ซ้าย | 'center': กลาง' | 'right': ขวา) * หากไม่ใส่จะเป็น 'right'
            priority = 'high',  -- ความสำคัญของ Notify นั้นๆ high จะอยู่บน และ low จะอยู่ล่าง * หากไม่ใส่จะเป็น 'medium'
            color = 'rgba(26, 129, 232, .8)',  -- สีของ title
            bgColor = 'rgba(255, 255, 255, 0.6)',  -- สีของพื้นหลัง
            descriptionColor = 'rgba(26, 129, 232, .8)',  -- สีของ description
            -- icon = 'ชื่อ Icon',  -- Icon (html/img/icons) ที่ต้องการให้แสดง (ใช้ไม่ได้กับ category = 'item')
            duration = 4000  -- ระยะเวลาการแสดง Notify
        })
    end)

    print('not have any of soap')
end


Notify.done = function()
    pcall(function()
        exports.nc_notify:PushNotification(playerId, {
            scale = 1.0,  -- ปรับขนาดของ Notify
            title = 'ความสะอาด',  -- หัวเรื่อง
            description = 'อาบน้ำเสร็จแล้ววว!',  -- รายละเอียด หากต้องการให้แสดงปุ่มกดให้ใช้ tag <btn></btn>
            type = 'success',  -- ชนิดของ Notify * หากไม่ใส่จะเป็น 'info'
            position = 'top',  -- ตำแหน่งการแสดง ('top': บน | 'bottom': ล่าง) * หากไม่ใส่จะเป็น 'top'
            direction = 'right',  -- ตำแหน่งการแสดง ('left': ซ้าย | 'center': กลาง' | 'right': ขวา) * หากไม่ใส่จะเป็น 'right'
            priority = 'medium',  -- ความสำคัญของ Notify นั้นๆ high จะอยู่บน และ low จะอยู่ล่าง * หากไม่ใส่จะเป็น 'medium'
            color = 'rgba(26, 129, 232, .8)',  -- สีของ title
            bgColor = 'rgba(255, 255, 255, 0.6)',  -- สีของพื้นหลัง
            descriptionColor = 'rgba(26, 129, 232, .8)',  -- สีของ description
            -- icon = 'ชื่อ Icon',  -- Icon (html/img/icons) ที่ต้องการให้แสดง (ใช้ไม่ได้กับ category = 'item')
            duration = 4000  -- ระยะเวลาการแสดง Notify
        })
    end)
end

Notify.stop = function()


end

