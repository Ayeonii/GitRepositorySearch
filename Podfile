# Uncomment the next line to define a global platform for your project
platform :ios, '14.0'

def commonPod
  pod 'SwiftyJSON', '~> 4.0'
  
  #Rx
  pod 'RxSwift', '6.1.0'
  pod 'RxGesture', '4.0.2'
  pod 'RxKeyboard', '2.0.0'
  pod 'ReactorKit', '3.2.0'
  
  #UI
  pod 'SnapKit'
  pod 'Then'
  
end

target 'GitRepositorySearch' do
  commonPod
end

target 'GitRepositorySearchTests' do
  commonPod
  pod 'RxTest'
  pod 'RxBlocking'
end
