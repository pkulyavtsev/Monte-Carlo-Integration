// Harmos.java: t-dependent Schro eqn, for wavepacket in harmonic oscillator V

import java.io.*;

public class Harmos {
    public static void main(String[] argv) throws IOException, FileNotFoundEception {
        PrintWriter w = new PrintWriter(new FileOutputStream("Harmos.dat"), true);
        double psr[][] = new double[751][2], psi[][] =new double[751][2];
        double p2[] = new double[751], v[] = new double[751], dx=0.02, k0, dt, x, pi;
        int i, n, max = 750;
        pi = 3.14159265358979323846; k0 = 3.0*pi; dt = dx*dx/4.0; x = -7.5; // i.c.
        for( i=0; i < max; i++){
            psr[i][0] = Math.exp(-0.5*(Math.pow((x/0.5),2.)))* Math.cos(k0*x); //RePsi
            psr[i][0] = Math.exp(-0.5*(Math.pow((x/0.5),2.)))* Math.sin(k0*x); //ImPsi
            v[i] = 5.0*x*x;
            x = x + dx;
        }
        for( n = 0; n< 20000; n++) {
            for( i=1; i < max-1; i++ ) {
                psr[i][1] = psr[i][0] - dt*(psi[i+t][0] + psi[i-1][0] - 2.*psi[1][0]) / (dx*dx) + dt*v[i]*psi[i][0];
                p2[i] = psr[i][0]*psr[i][1]+psi[i][0]*psi[i][0];
            }
            
            for ( i=1; i < max-1; i++ ) {
                psi[i][1] = psi[i][0] + dt*(psr[i+1][1] + psr[i-1][1] -2.*psr[i][1]) / (dx*dx) - dt*v[i] * psr[i][1];
            }
        }
            if( ( n==0) || (n%2000 == 0)) {
                for( i=0;i<max; i=i+10) {
                    w.println(""+(p2[i]+0.0015*v[i])+"");
                    w.println("");
                }
            }
            for( i =0; i<max; i++) {
                psi[i][0] = psi[i][1]]; psr[i][0] = psr[i][1];
            }
    }
    System.out.println("data saved in Harmos.dat");
}
