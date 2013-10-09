require 'sinatra'
require 'pry'

class PackedImagesApiApp < ApiBase
    get '/' do
        uri = URI.parse("http://localhost:9090/templates/builders")
        http = Net::HTTP.new(uri.host, uri.port)
        response = http.request(Net::HTTP::Get.new(uri.request_uri))
        [OK, response.body]
    end
    
    get '/builders' do
        uri = URI.parse("http://localhost:9090/templates/builders")
        http = Net::HTTP.new(uri.host, uri.port)
        response = http.request(Net::HTTP::Get.new(uri.request_uri))
        [OK, response.body]
    end
    
    get '/builders/:id' do
        uri = URI.parse("http://localhost:9090/templates/builders/"+params[:id])
        http = Net::HTTP.new(uri.host, uri.port)
        response = http.request(Net::HTTP::Get.new(uri.request_uri))
        [OK, response.body]
    end
    
    get '/provisioners' do
        uri = URI.parse("http://localhost:9090/templates/provisioners")
        http = Net::HTTP.new(uri.host, uri.port)
        response = http.request(Net::HTTP::Get.new(uri.request_uri))
        [OK, response.body]
    end
    
    get '/provisioners/:id' do
        uri = URI.parse("http://localhost:9090/templates/provisioners/"+params[:id])
        http = Net::HTTP.new(uri.host, uri.port)
        response = http.request(Net::HTTP::Get.new(uri.request_uri))
        [OK, response.body]
    end
    
    post '/save' do
        docid = params[:docid]
        response = nil
        if docid.nil?
            body = JSON.parse(request.body.read)
            packed_image = body['packed_image']
            http = Net::HTTP.new('localhost', 9090)
            response = http.send_request('PUT', '/packer/'+params[:uid],packed_image.to_json)
            PackedImage.create(name: body['name'],doc_id:JSON.parse(response.body)['Id'],org_id:params[:uid])
        else
            update_hash = {}
            mciaas_files = params['mciaas_files']
            
            m_files = {"centos6-ks.cfg" => {
                                            "type"=> "string",
                                            "content"=> "text\nskipx\ninstall\nurl --url http://mirror.raystedman.net/centos/6/os/x86_64/\nrepo --name=updates --baseurl=http://mirror.raystedman.net/centos/6/updates/x86_64/\nlang en_US.UTF-8\nkeyboard us\nrootpw s0m3password\nfirewall --disable\nauthconfig --enableshadow --passalgo=sha512\nselinux --disabled\ntimezone Etc/UTC\n%include /tmp/kspre.cfg\n\nservices --enabled=network,sshd/sendmail\n\npoweroff\n\n%packages --nobase\nat\nacpid\ncronie-noanacron\ncrontabs\nlogrotate\nmailx\nmlocate\nopenssh-clients\nopenssh-server\nrsync\nsendmail\ntmpwatch\nvixie-cron\nwhich\nwget\nyum\n-biosdevname\n-postfix\n-prelink\n%end\n\n%pre\n# Determine first drive name\ninstdrive=vda\n\nif [ -z \"$instdrive\" ] ; then\nexec < /dev/tty3 > /dev/tty3\nchvt 3\necho \"ERROR: Drive device does not exist at /dev/$bootdrive!\"\nsleep 5\nhalt -f\nfi\n\ncat >/tmp/kspre.cfg <<CFG\nzerombr\nbootloader --location=mbr --driveorder=$instdrive --append=\"nomodeset\"\nclearpart --all --initlabel\npart /boot --ondrive=$instdrive --fstype ext4 --fsoptions=\"relatime,nodev\" --size=512\npart pv.1 --ondrive=$instdrive --size 1 --grow\nvolgroup vg0 pv.1\nlogvol / --fstype ext4 --fsoptions=\"noatime,nodiratime,relatime,nodev\" --name=root --vgname=vg0 --size=4096\nlogvol swap --fstype swap --name=swap --vgname=vg0 --size 1 --grow\nCFG\n\n%end\n\n%post\n\n# touch /.autorelabel\n%end\n"
                                           }
                      }
            payload = {"builders"=>{"qemu" => {"mciaas_files" => m_files}}}
            #binding.pry
           
            uri = URI.parse("http://localhost:9090/packer/"+params[:uid]+"/"+docid)
            http = Net::HTTP.new(uri.host, uri.port)
            response = http.request(Net::HTTP::Post.new(uri.request_uri,payload.to_json))
        end
        [OK, response.body]
    end
    
    post '/deploy' do
        body = JSON.parse(request.body.read)
        packed_image = body['packed_image']
        docid = params[:docid]
        response = nil
        http = Net::HTTP.new('localhost', 9090)
        response = http.send_request('PUT', '/image/'+params[:uid]+'/'+params[:doc_id])
        [OK, response.body]
    end
    
    get '/templates/:id' do
        [OK, PackedImage.where(org_id:params[:id]).to_a.to_json]
    end
end
