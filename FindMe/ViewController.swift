//
//  ViewController.swift
//  FindMe
//
//  Created by Aluno on 14/10/22.
//

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate {

    //quanto mais pra direita, maior a longitude
    //quanto mais pra cima maior a latitude
    
    let lm = CLLocationManager()
    var timer = Timer()

    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var norte: UILabel!
    @IBOutlet weak var sul: UILabel!
    @IBOutlet weak var leste: UILabel!
    @IBOutlet weak var oeste: UILabel!
    @IBOutlet weak var tempoView: UILabel!
    
    var localFugitivo = CLLocation(latitude: Double.random(in: -90.0 ..< 90.0), longitude: Double.random(in: -180.0 ..< 180.0))
    
    var localJogador = CLLocation(latitude: Double.random(in: -90.0 ..< 90.0), longitude: Double.random(in: -180.0 ..< 180.0))
    var isAdress: Bool = false
    var pontos = 0
    var tempoEmSec = 999
    var distance = 0.0
    
    @IBOutlet weak var pontosText: UILabel!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
//        distance = localFugitivo.distance(from: map.centerCoordinate) / 1000
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.timeCounting), userInfo: nil, repeats: true)
        
        // qual objetivo vai receber as atualizações de localização
        lm.delegate = self
        
        // solicitar autorização do usuário
        lm.requestWhenInUseAuthorization()
        
        // precisão que o gps deve utilizar (gasta muita bateria)
        lm.desiredAccuracy = kCLLocationAccuracyHundredMeters
        
        // requisitar a localização
        lm.requestLocation()
        
        // iniciar a atualização
        lm.startUpdatingLocation()
        
        // definir o zoom (span)
        let zoom = MKCoordinateSpan(latitudeDelta: 0.0275, longitudeDelta: 0.0275)
        
        // definir a região (local + span)
        let regiao = MKCoordinateRegion(center: localJogador.coordinate, span: zoom)
        
        // associar a região ao mapa
        map.setRegion(regiao, animated: true)
        
        let anotacaoFugitivo = MKPointAnnotation()
        anotacaoFugitivo.coordinate = localFugitivo.coordinate
        print(anotacaoFugitivo.coordinate)
        anotacaoFugitivo.title = "O fugitivo está aqui"
        
        let anotacaoJogador = MKPointAnnotation()
        anotacaoJogador.coordinate = localJogador.coordinate
        anotacaoJogador.title = "Você está aqui"
        
        let zoomSize = MKMapView.CameraZoomRange(
            minCenterCoordinateDistance: 5000000,
            maxCenterCoordinateDistance: 5000000
        )
        map.setCameraZoomRange(zoomSize!, animated: true)
        map.addAnnotations([anotacaoJogador, anotacaoFugitivo])
        checkLatitude()
        checkLongitude()
        
    }
   
    override func touchesMoved (_ touches: Set<UITouch>, with event: UIEvent?) {
        checkLatitude()
        checkLongitude()
        checkWinner()
        checkDifference()
    }
    
    func checkDifference(){
        //eu teria que comparar os retangulos, tipo, o pegar o centro do retangulo do fugitivo, pegar o centro do retangulo do que esta sendo mostrado no mapa, e calcular a distancia entre os dois centros.
        let aux1 = distance
        let distanciaAtual = CLLocation(latitude: map.centerCoordinate.latitude, longitude: map.centerCoordinate.longitude).distance(from: localFugitivo)
        distance = distanciaAtual
        
        if aux1 >= distanciaAtual {
            print("caminho certo")
        } else {
            print("caminho errado")
        }
        
        print(distanciaAtual)
        print(aux1)
    }
    
    @objc func timeCounting () {
        tempoEmSec = tempoEmSec - 1
        tempoView.text = "Tempo: \(String(tempoEmSec))"
        if tempoEmSec == 0 {
            
            timer.invalidate()
            
            let timeOverAllert = UIAlertController(title: "O tempo acabou", message: "O fugitivo mudou de posição!", preferredStyle: .alert)
            
            let timeOverAction = UIAlertAction(title: "Procurar", style: .default) { UIAlertAction in
                self.tempoOver()
            }
            
            timeOverAllert.addAction(timeOverAction)
            self.present(timeOverAllert, animated: true)
        }
    }
    
    func tempoOver () {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.timeCounting), userInfo: nil, repeats: true)
        tempoEmSec = 30
        tempoView.text = "Tempo: \(String(tempoEmSec))"
        let anots = map.annotations
        let anot = anots.first!
        map.removeAnnotation(anot)
        self.localFugitivo = CLLocation(latitude: Double.random(in: -90.0 ..< 90.0), longitude: Double.random(in: -180.0 ..< 180.0))
        let anotacaoFugitivo = MKPointAnnotation()
        anotacaoFugitivo.coordinate = localFugitivo.coordinate
        anotacaoFugitivo.title = "O fugitivo está aqui"
        map.addAnnotation(anotacaoFugitivo)
        
    }
    
    func checkLatitude () {
        if map.region.center.latitude < localFugitivo.coordinate.latitude {
            norte.textColor = UIColor.green
            sul.textColor = UIColor.black
        } else {
            sul.textColor = UIColor.green
            norte.textColor = UIColor.black
        }
    }
    
    
    func checkLongitude () {
        if map.region.center.longitude < localFugitivo.coordinate.longitude {
            leste.textColor = UIColor.green
            oeste.textColor = UIColor.black
        } else {
            oeste.textColor = UIColor.green
            leste.textColor = UIColor.black
        }
    }
    
    func checkWinner () {
        let anots = map.annotations(in: map.visibleMapRect)
        if !anots.isEmpty {
            let anot = anots.first!.base as? MKPointAnnotation
            if anot?.title == "O fugitivo está aqui" {
                pontos += 1
                pontosText.text = String(pontos)

                // definir o zoom (spam)
                let zoom = MKCoordinateSpan(latitudeDelta: 0.0275, longitudeDelta: 0.0275)
                
                // definir a região (local + span)
                let regiao = MKCoordinateRegion(center: localFugitivo.coordinate, span: zoom)
                
                // associar a região ao mapa
                map.setRegion(regiao, animated: true)
                
                if pontos == 3 {
                    let winAlert = UIAlertController(title: "Parabéns, você venceu o jogo!", message: "Pontuação: \(String(pontos)) pontos", preferredStyle: .alert)
                    self.present(winAlert, animated: true, completion: nil)
                    timer.invalidate()
                }
                
                timer.invalidate()
                
                let winAlert = UIAlertController(title: "Parabéns", message: "Você encontrou o fugitivo!", preferredStyle: .alert)
                
                let resetGame = UIAlertAction(title: "Jogar Novamente", style: .default, handler: { (action) -> Void in
                    self.resetar(anot!)
                })
                
                winAlert.addAction(resetGame)
                
                self.present(winAlert, animated: true, completion: nil)
            }
        }
    }
    
    func resetar (_ deletAnot: MKPointAnnotation) {
        tempoEmSec = 30
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.timeCounting), userInfo: nil, repeats: true)
        map.removeAnnotation(deletAnot)
        localFugitivo = CLLocation(latitude: Double.random(in: -90.0 ..< 90.0), longitude: Double.random(in: -180.0 ..< 180.0))
        let anotacaoFugitivo = MKPointAnnotation()
        anotacaoFugitivo.coordinate = localFugitivo.coordinate
        print(anotacaoFugitivo.coordinate)
        anotacaoFugitivo.title = "O fugitivo está aqui"
        map.addAnnotation(anotacaoFugitivo)
    }
    
    // uma nova localização foi encontrada
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
    }
    
    // não foi possível atualizar a localização
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
    }


}

