Pod::Spec.new do |s|

    s.name              = 'LTGRoomPlaces'
    s.version           = '0.1.0'
    s.summary           = 'RoomPlaces API'
    s.homepage          = 'https://github.com/ltg-uic/ltg-room-places-cocoapod'
    s.license           = {
        :type => 'MIT',
        :file => 'LICENSE'
    }
    s.author            = {
        'Paulo Guerra' => 'paulinhog84@gmail.com'
    }
    s.source            = {
        :git => 'https://github.com/ltg-uic/ltg-room-places-cocoapod.git',
        :tag => s.version
    }
    s.source_files      = 'room-places-API/*.{h,swift}'
    s.requires_arc      = true

end