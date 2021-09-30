package wild

import (
	"encoding/json"
	"log"
	"net"
	"net/http"
)

type response struct {
	LangType string `json:"language_type"`
	Ip       string `json:"server_ip"`
}

func IndexHandler(w http.ResponseWriter, r *http.Request) {
	responseJson := response{
		LangType: "golang",
		Ip:       GetOutboundIP(),
	}

	enc := json.NewEncoder(w)
	enc.Encode(responseJson)

	//w.Write([]byte(fmt.Sprintf("Index Resource ", responseJson)))
}

// Get preferred outbound ip of this machine
func GetOutboundIP() string {
	conn, err := net.Dial("udp", "8.8.8.8:80")
	if err != nil {
		log.Fatal(err)
	}
	defer conn.Close()

	localAddr := conn.LocalAddr().(*net.UDPAddr)

	return localAddr.IP.String()
}
